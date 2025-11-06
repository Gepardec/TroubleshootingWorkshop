package com.gepardec.training;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import java.util.logging.Logger;

@Path("/api/slow")
public class SlowResource {

    private static final Logger LOG = Logger.getLogger(SlowResource.class.getName());
    private static int requestCounter = 0;

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String slowEndpoint() {
        long startTime = System.currentTimeMillis();
        int currentRequest = ++requestCounter;
        
        LOG.info(String.format("Request #%d started", currentRequest));
        
        try {
            Thread.sleep(2000); // 2 seconds
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return "Request interrupted";
        }
        
        long endTime = System.currentTimeMillis();
        long durationMs = endTime - startTime;
        double durationSec = durationMs / 1000.0;

        String response =  String.format("Request #%d completed in %.2f seconds",
                currentRequest, durationSec);

        LOG.info(response);
        
        return response;
    }
}
