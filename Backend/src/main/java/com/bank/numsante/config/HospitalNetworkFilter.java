package com.bank.numsante.config;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Arrays;
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
            "/api/v1/auth/login-patient",
            "/api/v1/auth/login-biometrique",
            "/api/v1/auth/enregistrer-biometrie",
            "/api/v1/patients/",
            "/api/v1/ordonnances/",
            "/api/v1/notifications/patient/"
    );

    // Endpoint de vérification réseau
    private static final String NETWORK_CHECK = "/api/v1/network/check";

    @Value("${hospital.allowed-networks:127.0.0.1,0:0:0:0:0:0:0:1,192.168.1.,10.0.2.,10.0.0.,172.16.}")
    private String allowedNetworksRaw;

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
            boolean isOnNetwork = isAllowedNetwork(clientIp);
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

        // Vérifier le réseau pour les autres routes
        if (!isAllowedNetwork(clientIp)) {
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

    private boolean isAllowedNetwork(String clientIp) {
        List<String> allowedNetworks = Arrays.asList(
                allowedNetworksRaw.split(","));
        return allowedNetworks.stream()
                .anyMatch(network -> clientIp.startsWith(network.trim()));
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