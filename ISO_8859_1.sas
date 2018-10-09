/*This program is saved with ISO-88591 Encoding. Please chekc following Latin characters. */
/*m�l� ��� ��*/
PROC FORMAT ;
    VALUE $gender 'f', 'F'='f�m�l�' 'm', 'M'='m�l�';
RUN;

/* Load data to CAS library */
data classformat;
    set sashelp.class;
    format sex $gender.;
run;

/*comment*/
