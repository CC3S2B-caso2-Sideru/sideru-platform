package com.sideru.backend.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class GatewayHeadersFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        if (httpRequest.getRequestURI().startsWith("/api/")
                && !"true".equals(httpRequest.getHeader("X-Gateway-Request"))) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Direct requests are not allowed.");
            return;
        }

        RequestContext context = new RequestContext(
                integerHeader(httpRequest, "X-Cliente-Id"),
                httpRequest.getHeader("X-Cliente-Nombre"),
                httpRequest.getHeader("X-Username"),
                httpRequest.getHeader("X-Rol"),
                httpRequest.getHeader("X-Tipo"),
                httpRequest.getHeader("X-Authorities")
        );

        RequestContextHolder.set(context);
        try {
            chain.doFilter(request, response);
        } finally {
            RequestContextHolder.clear();
        }
    }

    private Integer integerHeader(HttpServletRequest request, String name) {
        String val = request.getHeader(name);
        if (val != null && !val.isBlank()) {
            return Integer.parseInt(val);
        }
        return null;
    }
}
