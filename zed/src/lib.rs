use std::env;
use std::path::PathBuf;
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

        let root = PathBuf::from(worktree.root_path());
        let mut candidates = vec![
            root.join("tools").join("bin").join(binary_name),
            root.join("build").join(binary_name),
        ];

        let zed_dir = if os == Os::Windows {
            env::var_os("LOCALAPPDATA")
                .or_else(|| env::var_os("APPDATA"))
                .map(PathBuf::from)
                .map(|p| p.join("Zed"))
        } else {
            env::var_os("HOME")
                .map(PathBuf::from)
                .map(|p| p.join(".config").join("zed"))
        };
        if let Some(dir) = zed_dir.as_ref() {
            candidates.push(dir.join("tools").join("bin").join(binary_name));
            candidates.push(dir.join("bin").join(binary_name));
        }

        // The extension repository is commonly opened as the workspace while
        // the compiler/LSP repository is checked out beside it. Walk a few
        // ancestors so both `editor-extensions` and `editor-extensions/zed`
        // worktree roots are supported.
        let mut ancestor = root.as_path();
        for _ in 0..4 {
            if let Some(parent) = ancestor.parent() {
                candidates.push(
                    parent
                        .join("snova-lsp")
                        .join("tools")
                        .join("bin")
                        .join(binary_name),
                );
                candidates.push(parent.join("snova-lsp").join("build").join(binary_name));
                ancestor = parent;
            } else {
                break;
            }
        }

        let zed_bin_dir = zed_dir.as_ref().map(|dir| dir.join("tools").join("bin"));
        let command = worktree
            .which(binary_name)
            .or_else(|| {
                let local = root.join("tools").join("bin").join(binary_name);
                local.is_file().then(|| {
                    // Zed starts language servers from the worktree, and a
                    // relative command remains accessible in the extension
                    // sandbox where an absolute host path may be rejected.
                    format!("tools/bin/{binary_name}")
                })
            })
            .or_else(|| {
                candidates
                    .into_iter()
                    .find(|path| path.is_file())
                    .map(|path| path.to_string_lossy().into_owned())
            })
            .ok_or_else(|| {
                format!("{binary_name} was not found in PATH or a local tools/bin/build directory")
            })?;

        let mut env = Vec::new();
        if let Some(dir) = zed_bin_dir {
            if let Some(path) = env::var_os("PATH") {
                let mut paths = vec![dir.to_string_lossy().into_owned()];
                paths.push(path.to_string_lossy().into_owned());
                env.push((
                    "PATH".to_string(),
                    paths.join(if os == Os::Windows { ";" } else { ":" }),
                ));
            }
        }

        Ok(Command {
            command,
            args: vec!["--stdio".to_string()],
            env,
        })
    }
}

zed::register_extension!(SnovalangExtension);
