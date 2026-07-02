package com.sideru.backend.filter;

public class RequestContextHolder {

    private static final ThreadLocal<RequestContext> context = new ThreadLocal<>();

    public static void set(RequestContext ctx) { context.set(ctx); }

    public static RequestContext get() { return context.get(); }

    public static void clear() { context.remove(); }
}
