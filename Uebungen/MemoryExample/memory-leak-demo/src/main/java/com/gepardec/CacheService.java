package com.gepardec;

import jakarta.enterprise.context.ApplicationScoped;
import java.util.ArrayList;
import java.util.List;

@ApplicationScoped
public class CacheService {

    private final List<byte[]> mySafeCache = new ArrayList<>();

    public void add(byte[] data) {
        mySafeCache.add(data);
    }

    public int size() {
        return mySafeCache.size();
    }
}
