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

    private static final List<String> ALWAYS_ALLOWED = List.of(
            "/actuator",
            "/swagger-ui",
            "/api-docs",
            "/v3/api-docs",
            "/api/v1/auth/",
            "/api/v1/patients/enregistrer",
            "/api/v1/network/check"
    );

    @Value("${hospital.network.filter.enabled:false}")
    private boolean filterEnabled;

    @Value("${hospital.allowed-networks:127.0.0.1}")
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

        // Endpoint de vérification réseau — répond toujours
        if (path.equals("/api/v1/network/check")) {
            boolean isOnNetwork = !filterEnabled || isAllowedNetwork(clientIp);
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

        // Si filtre désactivé → tout passer
        if (!filterEnabled) {
            chain.doFilter(request, response);
            return;
        }

        // Filtre activé → vérifier l'IP
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
                .anyMatch(n -> clientIp.startsWith(n.trim()));
    }

    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isEmpty()
                && !"unknown".equalsIgnoreCase(ip)) {
            return ip.split(",")[0].trim();
        }
        ip = request.getHeader("X-Real-IP");
        if (ip != null && !ip.isEmpty()) { return ip; }
        return request.getRemoteAddr();
    }
}