use std::env;
use std::fs::{create_dir, read_dir};
use std::os::raw::c_char;
use std::path::{Path, PathBuf};
use std::sync::OnceLock;

const TMP_FOLDER_NAME: &str = "TMPDIR";
const NOTCH_FOLDER: &str = "notch";

static NOTCH_PATH: OnceLock<PathBuf> = OnceLock::new();

fn create_or_get_dir(tmp_folder: &'static str, notch_folder: &'static str) -> PathBuf {
    let tmp_folder = env::var(tmp_folder)
        .unwrap_or_else(|_| panic!("Error no enviroment folder found for {}", tmp_folder));

    let tmp_path = Path::new(&tmp_folder);
    let notch_path = tmp_path.join(notch_folder);

    println!("{:?}", notch_path);
    if !notch_path.exists() {
        create_dir(&notch_path)
            .unwrap_or_else(|_| panic!("Error could not create folder in {}", tmp_folder));
    }

    notch_path
}

fn get_files(path: PathBuf) -> Vec<String> {
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

    files
}

pub fn init_notch_path() -> bool {
    let path = create_or_get_dir(TMP_FOLDER_NAME, NOTCH_FOLDER);
    let _ = NOTCH_PATH.set(path);
    NOTCH_PATH.get().is_some()
}

#[repr(C)]
pub struct StringArray {
    data: *mut *mut c_char,
    len: usize,
}

#[unsafe(no_mangle)]
pub extern "C" fn get_files_from_notch() -> StringArray {
    use std::ffi::CString;

    let path = match NOTCH_PATH.get() {
        Some(p) => p,
        None => {
            return StringArray {
                data: std::ptr::null_mut(),
                len: 0,
            };
        }
    };

    let files = get_files(path.to_path_buf());
    let mut cstrings: Vec<CString> = files
        .into_iter()
        .filter_map(|s| CString::new(s).ok())
        .collect();

    // Build array of char* and leak them to C; provide a free function below.
    let mut ptrs: Vec<*mut c_char> = cstrings
        .iter_mut()
        .map(|s| s.as_ptr() as *mut c_char)
        .collect();

    // Prevent Rust from freeing the CStrings; C will free via free_string_array.
    std::mem::forget(cstrings);

    let data_ptr = ptrs.as_mut_ptr();
    let len = ptrs.len();
    std::mem::forget(ptrs);

    StringArray {
        data: data_ptr,
        len,
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn free_string_array(arr: StringArray) {
    use std::ffi::CString;
    if arr.data.is_null() {
        return;
    }
    unsafe {
        let slice = std::slice::from_raw_parts_mut(arr.data, arr.len);
        for &mut ptr in slice {
            if !ptr.is_null() {
                let _ = CString::from_raw(ptr); // frees each string
            }
        }
        let _ = Vec::from_raw_parts(arr.data, arr.len, arr.len); // frees the pointers array
    }
}
