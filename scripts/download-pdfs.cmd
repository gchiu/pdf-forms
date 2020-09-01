aws s3 cp s3://8th-dev/images/images/pdfs.zip .
copy pdfs.zip C:\Users\anon_\OneDrive\synapse\pdfs\pdfs.zip /y
copy pdfs.zip c:\Users\anon_\downloads\r3\pdfs.zip /y
del pdfs.zip
echo "PDFs in C:\Users\anon_\OneDrive\synapse\pdfs and in r3"
echo "Removing all old files"
del C:\Users\anon_\OneDrive\synapse\pdfs\SA*.*
del C:\Users\anon_\OneDrive\synapse\pdfs\images\SA*.*
cd c:\Users\anon_\downloads\r3
echo "Using Rebol to unzip"
r3 --do "unzip/verbose %%/c/Users/anon_/OneDrive/synapse/pdfs %%/c/Users/anon_/OneDrive/synapse/pdfs/pdfs.zip"
copy C:\Users\anon_\OneDrive\synapse\pdfs\images\SA*.* C:\Users\anon_\OneDrive\synapse\pdfs /y
echo "PDFs updated in Synapse pdfs directory"
echo "Done"
