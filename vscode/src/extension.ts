import * as path from "path";
import * as os from "os";
import { workspace, ExtensionContext } from "vscode";
import {
  LanguageClient,
  LanguageClientOptions,
  ServerOptions,
  TransportKind,
  Trace,
} from "vscode-languageclient/node";

let client: LanguageClient;

export function activate(context: ExtensionContext) {
  const config = workspace.getConfiguration("snova");
  const serverPath = config.get<string>("lsp.serverPath", "snova-lsp");
  const traceServer = config.get<string>("trace.server", "off");

  // Write LSP logs to a temp file when tracing is enabled
  const logArgs: string[] = [];
  if (traceServer !== "off") {
    const logPath = path.join(os.tmpdir(), "snova-lsp.log");
    logArgs.push("--log", logPath);
  }

  const serverOptions: ServerOptions = {
    command: serverPath,
    args: ["--stdio", ...logArgs],
    transport: TransportKind.stdio,
  };

  const clientOptions: LanguageClientOptions = {
    documentSelector: [
      { scheme: "file", language: "snova" },
      { scheme: "file", language: "snova-manifest" },
    ],
    synchronize: {
      // Watch .sno/.snova source files AND manifest files for workspace-wide refresh
      fileEvents: workspace.createFileSystemWatcher(
        "**/{*.snova,*.sno,mod.sno,snova.mod,snova.sno,snova.toml}"
      ),
    },
  };

  client = new LanguageClient(
    "snovaLanguageServer",
    "Snovalang Language Server",
    serverOptions,
    clientOptions,
  );

  // Apply trace level from settings
  const traceMap: Record<string, Trace> = {
    off:      Trace.Off,
    messages: Trace.Messages,
    verbose:  Trace.Verbose,
  };
  client.setTrace(traceMap[traceServer] ?? Trace.Off);

  client.start();
}

export function deactivate(): Thenable<void> | undefined {
  if (!client) {
    return undefined;
  }
  return client.stop();
}
