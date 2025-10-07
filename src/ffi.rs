use crate::{
    ffi_structs::{FFIResult, FFiErrorCodes, StringArray},
    files::{create_or_get_default_dir, create_or_get_dir, get_files, get_notch_path_rs},
};
use core::ffi::c_char;
use std::ffi::CString;

#[unsafe(no_mangle)]
pub extern "C" fn init_notch() -> FFIResult<()> {
    if let Ok(_) = create_or_get_default_dir() {
        return FFIResult::new(std::ptr::null_mut(), FFiErrorCodes::Ok);
    }
    return FFIResult::new(std::ptr::null_mut(), FFiErrorCodes::Error);
}

#[unsafe(no_mangle)]
pub extern "C" fn get_notch_path() -> FFIResult<c_char> {
    if let Ok(path) = get_notch_path_rs() {
        let c_string = CString::new(path.to_str().unwrap()).unwrap(); // TODO: handle more nicely
        return FFIResult::new(c_string.into_raw(), FFiErrorCodes::Ok);
    } else {
        return FFIResult::new(std::ptr::null_mut(), FFiErrorCodes::Error);
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn get_files_from_notch() -> FFIResult<StringArray> {
    use std::ffi::CString;
    if let Ok(path) = get_notch_path_rs() {
        let files = get_files(path.to_path_buf());
        let sa = StringArray::from(files);

        return FFIResult::new(&sa, FFiErrorCodes::Error);
    } else {
        return FFIResult::new(std::ptr::null_mut(), FFiErrorCodes::Error);
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
