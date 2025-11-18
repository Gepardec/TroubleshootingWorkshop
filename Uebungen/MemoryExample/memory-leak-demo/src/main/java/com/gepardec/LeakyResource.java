package com.gepardec;

import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.jboss.logging.Logger;

@Path("/leak")
public class LeakyResource {

    private static final Logger LOG = Logger.getLogger(LeakyResource.class);

    @Inject
    CacheService cacheService;

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String triggerLeak() {
        LOG.info("Triggering memory leak - allocating 10MB");
        // Each call adds 10MB of data that never gets garbage collected
        byte[] leakedData = new byte[10 * 1024 * 1024]; // 10 MB
        cacheService.add(leakedData);
        LOG.info("Memory leak triggered! Total leaked objects: " + cacheService.size() + " (" + (cacheService.size() * 10) + " MB)");
        
        return "Memory leak triggered! Total leaked objects: " + cacheService.size() +
               " (approximately " + (cacheService.size() * 10) + " MB)\n";
    }

    @GET
    @Path("/status")
    @Produces(MediaType.TEXT_PLAIN)
    public String getStatus() {
        Runtime runtime = Runtime.getRuntime();
        long usedMemory = (runtime.totalMemory() - runtime.freeMemory()) / (1024 * 1024);
        long maxMemory = runtime.maxMemory() / (1024 * 1024);
        
        LOG.info("Status check - Leaked objects: " + cacheService.size() + ", Used memory: " + usedMemory + " MB, Max memory: " + maxMemory + " MB");
        
        return String.format("Leaked objects: %d (%d MB)\nUsed memory: %d MB\nMax memory: %d MB\n",
                cacheService.size(),
                cacheService.size() * 10,
                usedMemory,
                maxMemory);
    }
}
