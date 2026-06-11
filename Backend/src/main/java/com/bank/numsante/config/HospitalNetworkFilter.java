package com.bank.numsante.config;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.List;

@Component
@Order(1)
public class HospitalNetworkFilter implements Filter {

    // Routes toujours accessibles (peu importe le réseau)
    private static final List<String> ALWAYS_ALLOWED = List.of(
            "/actuator",
            "/swagger-ui",
            "/api-docs",
            "/v3/api-docs",
            "/api/v1/auth/",
            "/api/v1/patients/",
            "/api/v1/ordonnances/",
            "/api/v1/notifications/patient/"
    );

    private static final String NETWORK_CHECK = "/api/v1/network/check";

    @Override
    public void doFilter(ServletRequest request,
                         ServletResponse response,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        String path = httpRequest.getRequestURI();
        String clientIp = getClientIp(httpRequest);

        // Endpoint de vérification réseau — toujours répondre
        if (path.equals(NETWORK_CHECK)) {
            boolean isOnNetwork = isPrivateNetwork(clientIp);
            httpResponse.setStatus(HttpServletResponse.SC_OK);
            httpResponse.setContentType("application/json");
            httpResponse.getWriter().write(
                    "{\"onHospitalNetwork\": " + isOnNetwork + "," +
                            "\"clientIp\": \"" + clientIp + "\"}"
            );
            return;
        }

        // Routes toujours autorisées
        boolean isAlwaysAllowed = ALWAYS_ALLOWED.stream()
                .anyMatch(path::startsWith);
        if (isAlwaysAllowed) {
            chain.doFilter(request, response);
            return;
        }

        // Vérifier que la requête vient d'un réseau privé (RFC 1918)
        if (!isPrivateNetwork(clientIp)) {
            httpResponse.setStatus(HttpServletResponse.SC_FORBIDDEN);
            httpResponse.setContentType("application/json");
            httpResponse.getWriter().write(
                    "{\"error\": \"NETWORK_RESTRICTED\"," +
                            "\"message\": \"Accès autorisé uniquement depuis " +
                            "le réseau des établissements partenaires.\"," +
                            "\"clientIp\": \"" + clientIp + "\"}"
            );
            return;
        }

        chain.doFilter(request, response);
    }

    /**
     * Accepte toute adresse IP privée (RFC 1918) et les loopbacks.
     * Pas d'IP codée en dur : fonctionne sur n'importe quel réseau local.
     */
    private boolean isPrivateNetwork(String ip) {
        if (ip == null) return false;

        // Loopback IPv4 / IPv6
        if (ip.equals("127.0.0.1") || ip.equals("::1")
                || ip.equals("0:0:0:0:0:0:0:1")) return true;

        String[] parts = ip.split("\\.");
        if (parts.length != 4) return false;

        try {
            int a = Integer.parseInt(parts[0]);
            int b = Integer.parseInt(parts[1]);

            // 10.0.0.0/8
            if (a == 10) return true;
            // 172.16.0.0/12  (172.16 – 172.31)
            if (a == 172 && b >= 16 && b <= 31) return true;
            // 192.168.0.0/16
            if (a == 192 && b == 168) return true;
        } catch (NumberFormatException e) {
            return false;
        }

        return false;
    }

    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isEmpty() && !"unknown".equalsIgnoreCase(ip)) {
            return ip.split(",")[0].trim();
        }
        ip = request.getHeader("X-Real-IP");
        if (ip != null && !ip.isEmpty()) {
            return ip;
        }
        return request.getRemoteAddr();
    }
}
