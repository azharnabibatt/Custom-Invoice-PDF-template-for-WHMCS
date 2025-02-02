<?php

# Logo
$logoFilename = 'placeholder.png';
if (file_exists(ROOTDIR . '/assets/img/logo.png')) {
    $logoFilename = 'logo.png';
} elseif (file_exists(ROOTDIR . '/assets/img/logo.jpg')) {
    $logoFilename = 'logo.jpg';
}
$pdf->Image(ROOTDIR . '/assets/img/' . $logoFilename, 15, 14, 52);

# Invoice Status
$statustext = $_LANG['invoices'.strtolower($status)];
$pdf->SetFillColor(223,85,74);
$pdf->SetDrawColor(171,49,43);
if ($status=="Paid") {
    $pdf->SetFillColor(151,223,74);
    $pdf->SetDrawColor(110,192,70);
}elseif ($status=="Cancelled") {
    $pdf->SetFillColor(200);
    $pdf->SetDrawColor(140);
} elseif ($status=="Refunded") {
    $pdf->SetFillColor(131,182,218);
    $pdf->SetDrawColor(91,136,182);
} elseif ($status=="Collections") {
    $pdf->SetFillColor(3,3,2);
    $pdf->SetDrawColor(127);
}
$pdf->SetXY(135,47);
$pdf->SetFont('freesans','B',15);
$pdf->SetTextColor(255);
$pdf->SetLineWidth(0);
$pdf->StartTransform();
$pdf->Rotate(0,100,225);
$pdf->Cell(60,10,strtoupper($statustext),'TB',0,'C','1');
$pdf->StopTransform();
$pdf->SetTextColor(0);

# Company Details
$pdf->SetXY(36,15);
$pdf->SetFont('freesans','B',11);
$pdf->Cell(160,6,trim($companyaddress[0]),0,1,'R');
$pdf->SetFont('freesans','',9);
for ( $i = 1; $i <= ((count($companyaddress)>6) ? count($companyaddress) : 6); $i += 1) {
	$pdf->Cell(180,4,trim($companyaddress[$i]),0,1,'R');
}
$pdf->Ln(1);

# Header Bar
$invoiceprefix = $_LANG["invoicenumber"];
/*
** This code should be uncommented for EU companies using the sequential invoice numbering so that when unpaid it is shown as a proforma invoice **
if ($status!="Paid") {
	$invoiceprefix = $_LANG["proformainvoicenumber"];
}
*/
$pdf->SetXY(15,59);
$pdf->SetFont('freesans','B',12);
$pdf->SetFillColor(539);
$pdf->Cell(0,3,$invoiceprefix.$invoicenum,0,1,'R','1');
$pdf->SetFont('freesans','',10);
$pdf->Cell(0,3,$_LANG["invoicesdatecreated"].': '.$datecreated.'',0,1,'R','1');
$pdf->Cell(0,3,$_LANG["invoicesdatedue"].': '.$duedate.'',0,1,'R','1');
$pdf->Ln(5);

$startpage = $pdf->GetPage();

# Clients Details
$pdf->SetXY(15,51);
$addressypos = $pdf->GetY();
$pdf->SetFont('freesans','B',12);
$pdf->Cell(0,5,$_LANG["invoicesinvoicedto"],0,1,'L');
$pdf->Ln(1);
$pdf->SetFont('freesans','',9);
if ($clientsdetails["companyname"]) {
	$pdf->Cell(0,4,$clientsdetails["companyname"],0,1,'L');
	$pdf->Cell(0,4,$_LANG["invoicesattn"].": ".$clientsdetails["firstname"]." ".$clientsdetails["lastname"],0,1,'L');
} else {
	$pdf->Cell(0,4,$clientsdetails["firstname"]." ".$clientsdetails["lastname"],0,1,'L');
}
$pdf->Cell(0,4,$clientsdetails["address1"].", ".$clientsdetails["city"].", ".$clientsdetails["postcode"],0,1,'L');
if ($clientsdetails["address2"]) {
	$pdf->Cell(0,4,$clientsdetails["address2"],0,1,'L');
}
$pdf->Cell(0,4,$clientsdetails["state"].", ".$clientsdetails["country"],0,1,'L');
if ($customfields) {
    $pdf->Ln();
    foreach ($customfields AS $customfield) {
        $pdf->Cell(0,4,$customfield['fieldname'].': '.$customfield['value'],0,1,'L');
    }
}
$pdf->Ln(10);

# Invoice Items
$tblhtml = '<table width="100%" bgcolor="#ccc" cellspacing="1" cellpadding="2" border="0">
    <tr height="30" bgcolor="#efefef" style="font-weight:bold;text-align:center;">
        <td width="80%">'.$_LANG['invoicesdescription'].'</td>
        <td width="20%">'.$_LANG['quotelinetotal'].'</td>
    </tr>';
foreach ($invoiceitems AS $item) {
    $tblhtml .= '
    <tr bgcolor="#fff">
        <td align="left">'.nl2br($item['description']).'<br /></td>
        <td align="center">'.$item['amount'].'</td>
    </tr>';
}
$tblhtml .= '
    <tr height="30" bgcolor="#efefef" style="font-weight:bold;">
        <td align="right">'.$_LANG['invoicessubtotal'].'</td>
        <td align="center">'.$subtotal.'</td>
    </tr>';
if ($taxname) $tblhtml .= '
    <tr height="30" bgcolor="#efefef" style="font-weight:bold;">
        <td align="right">'.$taxrate.'% '.$taxname.'</td>
        <td align="center">'.$tax.'</td>
    </tr>';
if ($taxname2) $tblhtml .= '
    <tr height="30" bgcolor="#efefef" style="font-weight:bold;">
        <td align="right">'.$taxrate2.'% '.$taxname2.'</td>
        <td align="center">'.$tax2.'</td>
    </tr>';
$tblhtml .= '
    <tr height="30" bgcolor="#efefef" style="font-weight:bold;">
        <td align="right">'.$_LANG['invoicescredit'].'</td>
        <td align="center">'.$credit.'</td>
    </tr>
    <tr height="30" bgcolor="#efefef" style="font-weight:bold;">
        <td align="right">'.$_LANG['invoicestotal'].'</td>
        <td align="center">'.$total.'</td>
    </tr>
</table>';

$pdf->writeHTML($tblhtml, true, false, false, false, '');

$pdf->Ln(2);

# Transactions
$pdf->SetFont('freesans','B',10);
$pdf->Cell(0,4,$_LANG["invoicestransactions"],0,1);

$pdf->Ln(2);

$pdf->SetFont('freesans','',9);

$tblhtml = '<table width="100%" bgcolor="#ccc" cellspacing="1" cellpadding="2" border="0">
    <tr height="30" bgcolor="#efefef" style="font-weight:bold;text-align:center;">
        <td width="25%">'.$_LANG['invoicestransdate'].'</td>
        <td width="25%">'.$_LANG['invoicestransgateway'].'</td>
        <td width="30%">'.$_LANG['invoicestransid'].'</td>
        <td width="20%">'.$_LANG['invoicestransamount'].'</td>
    </tr>';

if (!count($transactions)) {
    $tblhtml .= '
    <tr bgcolor="#fff">
        <td colspan="4" align="center">'.$_LANG['invoicestransnonefound'].'</td>
    </tr>';
} else {
    foreach ($transactions AS $trans) {
        $tblhtml .= '
        <tr bgcolor="#fff">
            <td align="center">'.$trans['date'].'</td>
            <td align="center">'.$trans['gateway'].'</td>
            <td align="center">'.$trans['transid'].'</td>
            <td align="center">'.$trans['amount'].'</td>
        </tr>';
    }
}
$tblhtml .= '
    <tr height="30" bgcolor="#efefef" style="font-weight:bold;">
        <td colspan="3" align="right">'.$_LANG['invoicesbalance'].'</td>
        <td align="center">'.$balance.'</td>
    </tr>
</table>';

$pdf->writeHTML($tblhtml, true, false, false, false, '');

# Notes
if ($notes) {
    $pdf->Ln(5);
	$pdf->SetFont('freesans','',9);
	$pdf->MultiCell(170,5,$_LANG["invoicesnotes"].": $notes");
}

#Payment Method
$pdf->Ln(2);

$pdf->SetFont('freesans','',9); 

$paymethhtml = '<table width="100%" cellspacing="1" cellpadding="2" border="0">
    <tr height="30">
        <td width="30%" style="text-align:left;"><strong>Bank Transfer</strong><br>0058021360000131<br />IFSC: JAKA0DECODE</td>
    <td width="70%" style="text-align:left;"><strong>Credit Alert!</strong><br>Payment is due within 45 days as per MSME regulations and can
lead to potentially higher taxes. Thank you for your prompt attention to this matter.</td>
        </tr></table>';

$pdf->writeHTML($paymethhtml, true, false, false, false, '');  

?>
