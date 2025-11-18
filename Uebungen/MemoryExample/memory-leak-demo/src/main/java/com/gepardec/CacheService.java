package com.gepardec;

import jakarta.enterprise.context.ApplicationScoped;
import org.jboss.logging.Logger;
import java.util.ArrayList;
import java.util.List;

@ApplicationScoped
public class CacheService {

    private static final Logger LOG = Logger.getLogger(CacheService.class);
    private final List<byte[]> mySafeCache = new ArrayList<>();

    public void add(byte[] data) {
        mySafeCache.add(data);
        LOG.debug("Added data to cache. Current cache size: " + mySafeCache.size());
    }

    public int size() {
        return mySafeCache.size();
    }
}
