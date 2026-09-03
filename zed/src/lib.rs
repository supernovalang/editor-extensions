use std::path::Path;
use zed_extension_api::{self as zed, Command, Extension, LanguageServerId, Os, Worktree};

struct SnovalangExtension;

impl Extension for SnovalangExtension {
    fn new() -> Self {
        Self
    }

    fn language_server_command(
        &mut self,
        language_server_id: &LanguageServerId,
        worktree: &Worktree,
    ) -> zed::Result<Command> {
        if language_server_id.as_ref() != "snova_lsp" {
            return Err(format!(
                "unknown Snovalang language server: {language_server_id}"
            ));
        }

        let (os, _) = zed::current_platform();
        let binary_name = if os == Os::Windows {
            "snova-lsp.exe"
        } else {
            "snova-lsp"
        };

        let local_lsp = if os == Os::Windows {
            format!("{}\\tools\\bin\\{}", worktree.root_path(), binary_name)
        } else {
            format!("{}/tools/bin/{}", worktree.root_path(), binary_name)
        };

        let command = worktree
            .which(binary_name)
            .or_else(|| Path::new(&local_lsp).exists().then_some(local_lsp))
            .ok_or_else(|| format!("{binary_name} was not found in PATH or tools/bin"))?;

        Ok(Command {
            command,
            args: vec!["--stdio".to_string()],
            env: Vec::new(),
        })
    }
}

zed::register_extension!(SnovalangExtension);
