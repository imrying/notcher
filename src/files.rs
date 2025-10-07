use std::path::{Path, PathBuf};
use std::sync::OnceLock;
use std::{
    env::{self, VarError},
    fs::{create_dir, read_dir},
};

use crate::ffi_structs::StringArray;

const TMP_FOLDER_NAME: &str = "TMPDIR";
const NOTCH_FOLDER: &str = "notch";
static NOTCH_PATH: OnceLock<PathBuf> = OnceLock::new();

pub struct FileArray {
    pub files: Vec<String>,
    pub len: usize,
}

impl FileArray {
    fn new(files: Vec<String>) -> Self {
        let len = files.len();
        FileArray { files, len }
    }
}

impl From<Vec<String>> for FileArray {
    fn from(files: Vec<String>) -> Self {
        FileArray::new(files)
    }
}

pub enum IOError {
    EnvVar(VarError),
    CreateDir,
    Io(std::io::Error),
}

impl From<std::io::Error> for IOError {
    fn from(err: std::io::Error) -> Self {
        IOError::Io(err)
    }
}

impl From<VarError> for IOError {
    fn from(err: VarError) -> Self {
        IOError::EnvVar(err)
    }
}

pub fn create_or_get_dir(tmp_folder: &str, notch_folder: &str) -> Result<PathBuf, IOError> {
    let tmp_folder = env::var(tmp_folder)?;
    // panic!("Error no enviroment folder found for {}", tmp_folder

    let tmp_path = Path::new(&tmp_folder);
    let notch_path = tmp_path.join(notch_folder);

    if NOTCH_PATH.get().is_none() {
        NOTCH_PATH.set(notch_path.clone());
    }
    if !notch_path.exists() {
        create_dir(&notch_path)?
    }
    // panic!("Error could not create folder in {}", tmp_folder))

    Ok(notch_path)
}

pub fn get_notch_path_rs() -> Result<PathBuf, ()> {
    if let Some(path) = NOTCH_PATH.get() {
        return Ok(path.to_path_buf());
    }
    Err(())
}

pub fn create_or_get_default_dir() -> Result<PathBuf, IOError> {
    create_or_get_dir(TMP_FOLDER_NAME, NOTCH_FOLDER)
}

pub fn get_files(path: PathBuf) -> FileArray {
    let mut files = Vec::new();

    if let Ok(entries) = read_dir(path) {
        for entry in entries.flatten() {
            let path = entry.path();

            // Only collect if it's a file (not a directory)
            if path.is_file()
                && let Some(name) = path.file_name().and_then(|n| n.to_str())
            {
                files.push(name.to_string());
            }
        }
    }
    FileArray::from(files)
}
