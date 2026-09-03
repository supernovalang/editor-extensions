import * as path from "path";
import { workspace, ExtensionContext } from "vscode";
import {
  LanguageClient,
  LanguageClientOptions,
  ServerOptions,
  TransportKind,
} from "vscode-languageclient/node";

let client: LanguageClient;

export function activate(context: ExtensionContext) {
  const config = workspace.getConfiguration("snova");
  const serverPath = config.get<string>("lsp.serverPath", "snova-lsp");

  const serverOptions: ServerOptions = {
    command: serverPath,
    args: ["--stdio"],
  };

  const clientOptions: LanguageClientOptions = {
    documentSelector: [
      { scheme: "file", language: "snova" },
      { scheme: "file", language: "snova-manifest" }
    ],
    synchronize: {
      fileEvents: workspace.createFileSystemWatcher("**/*.{snova,sno}"),
    },
  };

  client = new LanguageClient(
    "snovaLanguageServer",
    "Snovalang Language Server",
    serverOptions,
    clientOptions,
  );

  client.start();
}

export function deactivate(): Thenable<void> | undefined {
  if (!client) {
    return undefined;
  }
  return client.stop();
}
