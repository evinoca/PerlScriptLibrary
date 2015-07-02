use Spreadsheet::WriteExcel;   

# 创建一个新的EXCEL文件   
my $workbook = Spreadsheet::WriteExcel->new('PERL生成.xls');   

# 添加一个工作表   
$worksheet = $workbook->add_worksheet();   

# 新建一个样式   
$format = $workbook->add_format(); # Add a format   
$format->set_bold();#设置字体为粗体   
$format->set_color('red');#设置单元格前景色为红色   
$format->set_align('center');#设置单元格居中   

#使用行号及列号，向单元格写入一个格式化和末格式化的字符串   
$col = 1;
$row = 2;   
$worksheet->write($row, $col, 'Hi 2,1!', $format); 
$worksheet->write( $col-1, $row-1 , 'HI 0,1!');  
$worksheet->write(1,    $col, 'Hi 1,1!');   

#使用单元格名称（例：A1），向单元格中写一个数字。   
$worksheet->write('A3', 1.2345);   
$worksheet->write('A4', 'LOVE KUNKUN',$format);   
$worksheet->write('B3', 1);
$worksheet->write('B4', 2);
$worksheet->write('C3', 3);
$worksheet->write('D3', 4);
$worksheet->write('E3', 5);
$worksheet->write('F3', 6);