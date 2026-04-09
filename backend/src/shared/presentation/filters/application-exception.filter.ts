import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  ForbiddenException,
  HttpException,
  HttpStatus,
  UnauthorizedException,
} from '@nestjs/common';
import { Response } from 'express';
import { ConflictError } from '../../application/errors/conflict.error';
import { ForbiddenError } from '../../application/errors/forbidden.error';
import { NotFoundError } from '../../application/errors/not-found.error';
import { UnauthorizedError } from '../../application/errors/unauthorized.error';
import { DomainValidationError } from '../../domain/errors/domain-validation.error';

@Catch()
export class ApplicationExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost): void {
    const response = host.switchToHttp().getResponse<Response>();

    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const payload = exception.getResponse();

      response.status(status).json({
        statusCode: status,
        message: this.extractHttpMessage(payload),
      });

      return;
    }

    if (exception instanceof DomainValidationError) {
      response.status(HttpStatus.BAD_REQUEST).json({
        statusCode: HttpStatus.BAD_REQUEST,
        message: exception.message,
      });

      return;
    }

    if (exception instanceof NotFoundError) {
      response.status(HttpStatus.NOT_FOUND).json({
        statusCode: HttpStatus.NOT_FOUND,
        message: exception.message,
      });

      return;
    }

    if (exception instanceof ConflictError) {
      response.status(HttpStatus.CONFLICT).json({
        statusCode: HttpStatus.CONFLICT,
        message: exception.message,
      });

      return;
    }

    if (exception instanceof UnauthorizedError) {
      const httpException = new UnauthorizedException(exception.message);

      response.status(httpException.getStatus()).json({
        statusCode: httpException.getStatus(),
        message: exception.message,
      });

      return;
    }

    if (exception instanceof ForbiddenError) {
      const httpException = new ForbiddenException(exception.message);

      response.status(httpException.getStatus()).json({
        statusCode: httpException.getStatus(),
        message: exception.message,
      });

      return;
    }

    response.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
      statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
      message: 'Internal server error',
    });
  }

  private extractHttpMessage(payload: string | object): string | string[] {
    if (typeof payload === 'string') {
      return payload;
    }

    if ('message' in payload) {
      return payload.message as string | string[];
    }

    return 'Unexpected error';
  }
}
