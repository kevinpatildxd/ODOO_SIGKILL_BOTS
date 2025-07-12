/**
 * Caching utilities for improved performance
 */
const NodeCache = require('node-cache');
const { computeETag } = require('./helpers');
const logger = require('./logger');

// Default cache TTL (Time To Live) in seconds
const DEFAULT_TTL = 300; // 5 minutes

// Create a cache instance with default settings
const cache = new NodeCache({
  stdTTL: DEFAULT_TTL,
  checkperiod: 120, // Check for expired entries every 2 minutes
  useClones: false, // Don't clone objects (for better performance)
  deleteOnExpire: true
});

/**
 * Set a value in cache
 * @param {String} key - Cache key
 * @param {any} value - Value to cache
 * @param {Number} ttl - Time to live in seconds (optional, defaults to DEFAULT_TTL)
 * @returns {Boolean} True if successfully set, false otherwise
 */
const set = (key, value, ttl = DEFAULT_TTL) => {
  try {
    return cache.set(key, value, ttl);
  } catch (error) {
    logger.error('Cache set error:', { key, error: error.message });
    return false;
  }
};

/**
 * Get a value from cache
 * @param {String} key - Cache key
 * @returns {any|undefined} Cached value or undefined if not found
 */
const get = (key) => {
  try {
    return cache.get(key);
  } catch (error) {
    logger.error('Cache get error:', { key, error: error.message });
    return undefined;
  }
};

/**
 * Remove a value from cache
 * @param {String} key - Cache key
 * @returns {Number} Number of items removed (0 or 1)
 */
const del = (key) => {
  try {
    return cache.del(key);
  } catch (error) {
    logger.error('Cache delete error:', { key, error: error.message });
    return 0;
  }
};

/**
 * Clear the entire cache
 * @returns {Boolean} True if successfully cleared, false otherwise
 */
const clear = () => {
  try {
    cache.flushAll();
    return true;
  } catch (error) {
    logger.error('Cache clear error:', { error: error.message });
    return false;
  }
};

/**
 * Get cache statistics
 * @returns {Object} Cache statistics
 */
const stats = () => {
  return cache.getStats();
};

/**
 * Get all cache keys
 * @returns {Array} Array of cache keys
 */
const keys = () => {
  return cache.keys();
};

/**
 * Delete a group of cache entries by prefix
 * @param {String} prefix - Key prefix to match
 * @returns {Number} Number of items deleted
 */
const deleteByPrefix = (prefix) => {
  try {
    const keysToDelete = cache.keys().filter(key => key.startsWith(prefix));
    return cache.del(keysToDelete);
  } catch (error) {
    logger.error('Cache deleteByPrefix error:', { prefix, error: error.message });
    return 0;
  }
};

/**
 * Middleware for response caching
 * @param {Number} ttl - Cache time to live in seconds
 * @param {Function} keyFn - Function to generate cache key (default: uses request URL)
 * @returns {Function} Express middleware
 */
const cacheMiddleware = (ttl = DEFAULT_TTL, keyFn = (req) => req.originalUrl) => {
  return (req, res, next) => {
    // Skip caching for non-GET requests
    if (req.method !== 'GET') {
      return next();
    }

    const key = keyFn(req);
    const cachedResponse = get(key);

    if (cachedResponse) {
      // Serve from cache
      logger.debug('Cache hit:', { key });
      res.set('X-Cache', 'HIT');
      res.set('ETag', cachedResponse.etag);
      
      // Check If-None-Match header for 304 response
      const clientETag = req.headers['if-none-match'];
      if (clientETag && clientETag === cachedResponse.etag) {
        return res.status(304).end();
      }
      
      return res.json(cachedResponse.data);
    }

    logger.debug('Cache miss:', { key });
    res.set('X-Cache', 'MISS');

    // Capture the original res.json method
    const originalJson = res.json;

    // Override res.json to cache the response before sending
    res.json = function(data) {
      if (res.statusCode === 200) {
        const etag = computeETag(data);
        set(key, { data, etag }, ttl);
        res.set('ETag', etag);
      }

      // Call the original method
      return originalJson.call(this, data);
    };

    next();
  };
};

module.exports = {
  set,
  get,
  del,
  clear,
  stats,
  keys,
  deleteByPrefix,
  cacheMiddleware,
  DEFAULT_TTL
}; 