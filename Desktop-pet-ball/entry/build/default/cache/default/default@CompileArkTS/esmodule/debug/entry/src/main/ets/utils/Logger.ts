export enum LogLevel {
    ERROR = 0,
    WARN = 1,
    INFO = 2,
    DEBUG = 3
}
export class LogContext {
    private data: Map<string, string | number | boolean | Error> = new Map();
    set(key: string, value: string | number | boolean | Error): void {
        this.data.set(key, value);
    }
    get(key: string): string | number | boolean | Error | undefined {
        return this.data.get(key);
    }
    has(key: string): boolean {
        return this.data.has(key);
    }
    toString(): string {
        const parts: string[] = [];
        this.data.forEach((value, key) => {
            parts.push(`${key}=${value}`);
        });
        return parts.join(', ');
    }
}
export interface LogEntry {
    level: LogLevel;
    module: string;
    message: string;
    timestamp: number;
    context?: LogContext;
}
export class Logger {
    private static instance: Logger;
    private logLevel: LogLevel = LogLevel.INFO;
    private logHistory: LogEntry[] = [];
    private maxHistorySize: number = 1000;
    private moduleEnabled: Map<string, boolean> = new Map();
    private constructor() { }
    static getInstance(): Logger {
        if (!Logger.instance) {
            Logger.instance = new Logger();
        }
        return Logger.instance;
    }
    setLogLevel(level: LogLevel): void {
        this.logLevel = level;
    }
    enableModule(module: string, enabled: boolean): void {
        this.moduleEnabled.set(module, enabled);
    }
    private shouldLog(level: LogLevel, module: string): boolean {
        if (level > this.logLevel) {
            return false;
        }
        const moduleEnabled = this.moduleEnabled.get(module);
        if (moduleEnabled !== undefined && !moduleEnabled) {
            return false;
        }
        return true;
    }
    private formatMessage(entry: LogEntry): string {
        const levelStr = LogLevel[entry.level];
        const timestamp = new Date(entry.timestamp).toISOString();
        let message = `[${timestamp}] [${levelStr}] [${entry.module}] ${entry.message}`;
        if (entry.context) {
            message += ` | Context: {${entry.context.toString()}}`;
        }
        return message;
    }
    private log(entry: LogEntry): void {
        if (!this.shouldLog(entry.level, entry.module)) {
            return;
        }
        this.logHistory.push(entry);
        if (this.logHistory.length > this.maxHistorySize) {
            this.logHistory.shift();
        }
        const formattedMessage = this.formatMessage(entry);
        switch (entry.level) {
            case LogLevel.ERROR:
                console.error(formattedMessage);
                break;
            case LogLevel.WARN:
                console.warn(formattedMessage);
                break;
            case LogLevel.INFO:
                console.info(formattedMessage);
                break;
            case LogLevel.DEBUG:
                console.debug(formattedMessage);
                break;
        }
    }
    error(module: string, message: string, context?: LogContext): void {
        const entry: LogEntry = {
            level: LogLevel.ERROR,
            module: module,
            message: message,
            timestamp: Date.now(),
            context: context
        };
        this.log(entry);
    }
    warn(module: string, message: string, context?: LogContext): void {
        const entry: LogEntry = {
            level: LogLevel.WARN,
            module: module,
            message: message,
            timestamp: Date.now(),
            context: context
        };
        this.log(entry);
    }
    info(module: string, message: string, context?: LogContext): void {
        const entry: LogEntry = {
            level: LogLevel.INFO,
            module: module,
            message: message,
            timestamp: Date.now(),
            context: context
        };
        this.log(entry);
    }
    debug(module: string, message: string, context?: LogContext): void {
        const entry: LogEntry = {
            level: LogLevel.DEBUG,
            module: module,
            message: message,
            timestamp: Date.now(),
            context: context
        };
        this.log(entry);
    }
    getLogHistory(): LogEntry[] {
        return [...this.logHistory];
    }
    getLogsByModule(module: string): LogEntry[] {
        return this.logHistory.filter(entry => entry.module === module);
    }
    getLogsByLevel(level: LogLevel): LogEntry[] {
        return this.logHistory.filter(entry => entry.level === level);
    }
    clearHistory(): void {
        this.logHistory = [];
    }
    exportLogs(): string {
        return this.logHistory
            .map(entry => this.formatMessage(entry))
            .join('\n');
    }
}
