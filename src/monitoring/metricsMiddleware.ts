import { Request, Response, NextFunction } from 'express';
import { httpRequestCounter, httpRequestDuration } from './metrics';

export function metricsMiddleware(req: Request, res: Response, next: NextFunction) {
  const start = process.hrtime();

  res.on('finish', () => {
    const routePath = req.route?.path;
    const route = req.baseUrl + (routePath === '/' ? '' : (routePath ?? req.path));
    const labels = {
      method: req.method,
      route,
      status_code: res.statusCode.toString(),
    };

    httpRequestCounter.inc(labels);

    const [seconds, nanoseconds] = process.hrtime(start);
    const durationInSeconds = seconds + nanoseconds / 1e9;
    httpRequestDuration.observe(labels, durationInSeconds);
  });

  next();
}
