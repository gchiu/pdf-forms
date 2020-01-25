rebol [
    file: %grab-pdfs.reb
    name: "Grab PDFs"
    date: 24-Jan-2020
    author: "Graham Chiu"
]

; Pharmac puts an index of all the Special authorities on this page
pdfs: https://www.pharmac.govt.nz/wwwtrs/SAForms.php

; and this is their download directory
base: https://www.pharmac.govt.nz/latest/

; these are the drugs we use and are interested in.  Check their page (pdfs) to see what other drugs are supported
wanted: ["Adalimumab" "Etanercept" "Teriparatide" "Aclasta" "Benzbromarone"]

; read the page and turn into text for parsing out the download links
data: to text! read pdfs 

; store the data as pairs here
drugs: copy []

; this is what we have to parse out .. we want the pdf name, and the drug name
; <td><a href='/latest/SA1847.pdf'>SA1847 - Adalimumab</a> (20 pages, 235 KB)</td>

; parse the downloaded web page (data) and extract all the links we want
parse data [
    some [
        thru {<a href='/latest/} copy sa to {'} thru " - " copy name to </a> (
            ; dump name
            if find wanted name [
                append/only drugs reduce [name sa]
            ]
        )
    ]
]

; sample capture stored in the drugs block
; drugs [["Benzbromarone" "SA1537.pdf"] ["Teriparatide" "SA1139.pdf"] ["Adalimumab" "SA1847.pdf"] ["Etanercept" "SA1812.pdf"]]

; download each pdf and save it to the local filesystem 
for-each pair drugs [
    probe pair/1
    print unspaced [base pair/2]
    write to file! pair/2 read to url! join base pair/2
]

; use pdftk to burst the pdf into single pages named pg_nn.pdf
for-each pair drugs [
    ; delete the last split files that aren't being used
    attempt [ delete pg_*.pdf ]
    print "bursting"
	  call rejoin [ "pdftk " to file! pair/2 " burst" ]
    cnt: 1
    pdf: pair/2
    ; get the name of the file less the .pdf extension
    root: copy/part pdf find pdf %.pdf
	
	  ; now convert each of the pages created
	  forever [
      either exists? single-pdf: to file! unspaced [ %pg_ next form 10000 + cnt %.pdf ] [
        ; if a pg_nn.pdf exists, then create a png from the PDF using ghostscript
        print rejoin [ "creating " root "-" cnt %.png ]
        ; need to fix this for linux
        script: rejoin [ "gswin32c -dSAFER -dBATCH -dNOPAUSE -sDEVICE=png16m -r300 -sOutputFile="
          rejoin [ root "-" cnt %.png ] " " single-pdf ]
        call script
        ; call script
        ; and now turn the same PDF into an eps file
        print rejoin [ "creating EPS " root "-" cnt %.eps ]
        script: rejoin [ "gswin32c -o " rejoin [ root "-" cnt %.eps ] " -sPAPERSIZE=a4 -sDEVICE=epswrite " single-pdf ]
        ; call/wait script
        call script
        cnt: me + 1
      ][
        ; no more pages, so go to next download in set of PDFs
        break
      ]
	]
]

quit
