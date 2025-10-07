use std::ffi::c_char;

use crate::files::FileArray;

#[repr(C)]
pub struct StringArray {
    data: *mut *mut c_char,
    len: usize,
}

impl StringArray {
    pub fn new(data_ptr: *mut *mut c_char, len: usize) -> Self {
        Self {
            data: data_ptr,
            len,
        }
    }
}

impl From<FileArray> for StringArray {
    fn from(file_array: FileArray) -> Self {
        use std::ffi::CString;
        let mut cstrings: Vec<CString> = file_array
            .files
            .into_iter()
            .filter_map(|s| CString::new(s).ok())
            .collect();

        // Build array of char* and leak them to C; provide a free function below.
        let mut ptrs: Vec<*mut std::os::raw::c_char> = cstrings
            .iter_mut()
            .map(|s| s.as_ptr() as *mut std::os::raw::c_char)
            .collect();

        // Prevent Rust from freeing the CStrings; C will free via free_string_array.
        std::mem::forget(cstrings);

        let data_ptr = ptrs.as_mut_ptr();
        let len = ptrs.len();
        std::mem::forget(ptrs);

        StringArray::new(data_ptr, len)
    }
}
