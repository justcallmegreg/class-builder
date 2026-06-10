# Rate limiting

We use a token-bucket algorithm. Each client gets a bucket of N tokens that
refills at R tokens/second. A request costs one token; an empty bucket returns
HTTP 429. Chosen over fixed-window because it smooths bursts without sharp
boundary spikes.
