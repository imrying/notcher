use crate::files::{create_or_get_default_dir, create_or_get_dir, get_files};
use core::ffi::c_char;

#[unsafe(no_mangle)]
pub extern "C" fn init_notch() -> bool {
    if let Ok(path) = create_or_get_default_dir() {
        return true;
    }
    false
}

#[unsafe(no_mangle)]
pub extern "C" fn get_notch_path() -> *const c_char {
    use std::ffi::CString;
    let s = NOTCH_PATH.get().unwrap().to_str().unwrap();

    let c_string = CString::new(s).unwrap();
    c_string.into_raw()
}

#[unsafe(no_mangle)]
pub extern "C" fn get_files_from_notch() -> StringArray {
    use std::ffi::CString;

    // println!("NOTCH PATH: {:?}", NOTCH_PATH);
    // init_notch_path();

    let path = match NOTCH_PATH.get() {
        Some(p) => p,
        None => {
            println!("NO NOTCH PATH SET");
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
