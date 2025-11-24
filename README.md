 nasm-xor-encryptor

A 64-bit NASM assembly project that encrypts and decrypts files using a simple XOR-based algorithm.  
This project demonstrates low-level file I/O, basic cryptography, and use of C runtime functions in assembly on Windows.

---

🔐 Description

This repository contains a 64-bit NASM assembly program that performs **file encryption and decryption using XOR**.

The program:

- Reads data from an **input file** (e.g. `input.txt`)
- Encrypts each byte using a **single-byte XOR key**
- Writes the processed data to an **output file** (e.g. `output.txt`)
- If you run the program again on the encrypted file with the **same key**, it will **decrypt** the content back to its original form

This project was created as a **course project** to understand:

- How encryption works at the **lowest (assembly) level**
- How to handle **files** using assembly language
- How to use **C runtime functions** from NASM (like `fopen`, `fread`, `fwrite`, `fclose`, `printf`, `scanf`)

---

 🧰 Technologies & Tools

- **Language:** Assembly (x86-64 / NASM syntax)
- **Assembler:** NASM (Netwide Assembler)
- **Linker:** GoLink (or MinGW `gcc` as an alternative)
- **Platform:** Windows 64-bit
- **Libraries:**
  - `msvcrt.dll` (C runtime – for `printf`, `scanf`, `fopen`, `fread`, `fwrite`, `fclose`, `getchar`)

---

📁 Project Structure


.
├── encrypt64.asm      # Main assembly source file
├── encrypt64.obj      # Object file (generated after assembling)
├── encrypt64.exe      # Final executable (generated after linking)
├── input.txt          # Sample input file (plain text)
└── README.md          # Project documentation


⚙️ How It Works (High Level)
The program asks the user for:

Input file name

Output file name

A single-character encryption key

It opens the input file in binary read mode (rb).

It opens/creates the output file in binary write mode (wb).

It reads the file in blocks (e.g. 4096 bytes).

For every byte in the buffer:

asm
Copy code
xor byte [rdi], al
where al contains the key.

The encrypted (or decrypted) bytes are written to the output file.

This repeats until the end of file is reached.

Both files are closed and a completion message is shown.

Because XOR is symmetric, the same program + same key will decrypt what it encrypted:

(Data XOR Key) XOR Key
=
Original Data
(Data XOR Key) XOR Key=Original Data
🧪 Example Usage
1. Prepare Input File
Create a file input.txt in the same folder as the executable, with some text:

text
Copy code
Hello World
This is a test file.
2. Run the Program
On Windows CMD, in the folder of encrypt64.exe:

bash
Copy code
encrypt64.exe
Sample interaction:

text
Copy code
Enter input file name: input.txt
Enter output file name: output.txt
Enter key (single char): A

✅ Done! Check output file.
Press Enter to exit...
Now:

output.txt contains encrypted data (unreadable text).

If you run the program again but now use:

input: output.txt

output: decrypted.txt

same key: A

Then decrypted.txt will contain the original text.

🧱 Build Instructions
✅ Requirements
Windows 64-bit

NASM installed and available in PATH

GoLink OR MinGW GCC installed

🔧 Assemble with NASM
bash
Copy code
nasm -f win64 encrypt64.asm -o encrypt64.obj
🔗 Link Option 1 — Using GoLink
bash
Copy code
GoLink /console encrypt64.obj msvcrt.dll
This will produce encrypt64.exe in the same folder.

🔗 Link Option 2 — Using MinGW GCC (if installed)
bash
Copy code
gcc encrypt64.obj -o encrypt64.exe -lmsvcrt
Note: Linking steps can vary depending on installation paths and tools.
Adjust commands according to your environment.

🧬 Core Logic (Code Snippet)
A simplified view of the XOR loop:

asm
Copy code
; rax = number of bytes read
; buffer = address of data
mov     rdi, buf        ; pointer to buffer
mov     rcx, rax        ; loop counter = bytes read
mov     al, [key]       ; load XOR key

xor_loop:
    xor byte [rdi], al  ; XOR each byte with key
    inc rdi             ; move to next byte
    loop xor_loop       ; rcx-- and repeat if not zero
This same logic both encrypts and decrypts.
