(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)

unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Forms, Dialogs,
  objetos, Menus, ExtCtrls, Grids, StdCtrls, Controls;

const
   Nombre_Archivo='..\laa\bin\obj.b';
   Nombre_A_Objetos='..\laa\grf\obj.jpg';
//IdRecursos:
   idIndefinido=0;

type
  TForm1 = class(TForm)
    CB_Clase: TComboBox;
    SG_Nombres: TStringGrid;
    Label8: TLabel;
    LbCodigo: TLabel;
    Label3: TLabel;
    E_MO: TEdit;
    E_MP: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    LB_Modificador: TLabel;
    E_ModADC: TEdit;
    Label7: TLabel;
    Label9: TLabel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;
    CheckBox16: TCheckBox;
    GB_armadura: TGroupBox;
    e_Cort: TEdit;
    E_punz: TEdit;
    E_golp: TEdit;
    GB_arma: TGroupBox;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    D1_base: TEdit;
    D2_base: TEdit;
    d1_plus: TEdit;
    d2_plus: TEdit;
    E_magi: TEdit;
    cb_peso: TComboBox;
    Label10: TLabel;
    Label11: TLabel;
    cb_tipo: TComboBox;
    LB_rango: TLabel;
    PaintBox: TPaintBox;
    MainMenu1: TMainMenu;
    Archivo1: TMenuItem;
    Herramientas1: TMenuItem;
    GuardarTodo1: TMenuItem;
    Abrirnuevamente1: TMenuItem;
    Bevel1: TBevel;
    gbRecursos: TGroupBox;
    Lb_recurso1: TLabel;
    Lb_recurso2: TLabel;
    Lb_recurso3: TLabel;
    E_recurso1: TEdit;
    E_recurso2: TEdit;
    E_recurso3: TEdit;
    LB_cantidad: TLabel;
    E_nivelConst: TEdit;
    E_Cantidad: TEdit;
    Lb_NivelConst: TLabel;
    N2: TMenuItem;
    LBDescripcion: TLabel;
    Crearmanualdearmas1: TMenuItem;
    Crearmanualdearmasconjuradas1: TMenuItem;
    Crearmanualdearmadurasvestimentas1: TMenuItem;
    Bevel2: TBevel;
    Bevel3: TBevel;
    LbCostoMP: TLabel;
    N1: TMenuItem;
    E_nivelminimo: TEdit;
    Label2: TLabel;
    Label6: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Crearlistadeiconos1: TMenuItem;
    cb_animacion: TComboBox;
    lbTipo: TLabel;
    CB_Tipoconstructor: TComboBox;
    CB_Reparacion: TComboBox;
    Lb_Recursos: TLabel;
    Bevel4: TBevel;
    procedure GuardarClick(Sender: TObject);
    procedure LimpiarCadenasClick(Sender: TObject);
    procedure CB_ClaseChange(Sender: TObject);
    procedure CB_ClaseEnter(Sender: TObject);
    procedure SG_NombresSelectCell(Sender: TObject; Col, Row: Integer;
      var CanSelect: Boolean);
    procedure BtAbrirClick(Sender: TObject);
    procedure E_MOExit(Sender: TObject);
    procedure E_MPExit(Sender: TObject);
    procedure E_ModADCExit(Sender: TObject);

    procedure E_TipoDannoExit(Sender: TObject);
    procedure D_baseExit(Sender: TObject);
    procedure D_plusExit(Sender: TObject);
    procedure recursoExit(Sender: TObject);
    procedure CB_TipoconstructorChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure Salir1Click(Sender: TObject);
    procedure Crearmanualdearmas1Click(Sender: TObject);
    procedure Crearmanualdearmasconjuradas1Click(Sender: TObject);
    procedure Crearmanualdearmadurasvestimentas1Click(Sender: TObject);
    procedure E_MPChange(Sender: TObject);
    procedure E_nivelConstExit(Sender: TObject);
    procedure Crearlistadeiconos1Click(Sender: TObject);
  private
    { Private declarations }
    CarpetaPrincipal:string;
    Info:TArchivoObjetos;
    clase,tipo:byte;
    CodigoAnterior:integer;
    Graficos:TBitmap;
    procedure AlaLista;
    procedure LlenarNombresClaseActualEnElGrid;
    procedure MostrarInfo;
    procedure GuardarInfo;
    function controlar(const cdn:string;const inf,sup:integer):string;
    function valor(const cdn:string;const inf,sup:integer):integer;
    function MostrarComoArma(idObjeto:byte):boolean;
    function DescribirAlcanceArma(Alcance:TAlcanceArma):string;
    procedure GuardarInformacionConstruccion(var inf:TDescriptorObjeto;idObj:byte);
    procedure crearIcono(indice:byte);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
{$R *.DFM}
//GifImage es una biblioteca que permite abrir y guardar archivos .gif
//También es posible utilizar el formato jpg para guardar los íconos de
//artefactos sin recurrir al formato gif.
uses jpeg,gifimage;
const extension_GRF='.gif';//'.jpg';

procedure Tform1.crearIcono(indice:byte);
var archivo:string;
    BitmapTemp:Tbitmap;
begin
  try
    archivo:=CarpetaPrincipal+'\icob\'+inttostr(indice)+extension_GRF;
  //  if fileexists(archivo) then exit;
    BitmapTemp:=Tbitmap.create;
    with BitmapTemp do
    begin
      HandleType:=bmDIB;
      PixelFormat:=pf24bit;
      Width:=40;
      Height:=40;
      bitblt(canvas.handle,0,0,40,40,Graficos.canvas.handle,(indice and $7)*40,(indice shr 3)*40,SRCCOPY);
    end;
    with TgifImage.create do
    begin
      DitherMode:=dmNearest;
      ColorReduction:=rmQuantize;
      ReductionBits:=5;
      Compression:=gcLZW;
      Assign(BitmapTemp);
      Optimize([ooCleanup,ooColorMap,ooMerge],rmQuantize,dmNearest,5);
      saveToFile(archivo);
      free;
    end;
    BitmapTemp.free;
  except
    showmessage('Crea una carpeta "icob" para los íconos.');
  end;
end;

procedure Tform1.GuardarInformacionConstruccion(var inf:TDescriptorObjeto;idObj:byte);
var i:integer;
begin
  with inf do
  begin
    CantidadConstruida:=valor(e_cantidad.text,0,255);
    cantidadX[0]:=valor(E_recurso1.text,0,255);
    cantidadX[1]:=valor(E_recurso2.text,0,255);
    cantidadX[2]:=valor(E_recurso3.text,0,255);
    construye:=TClaseConstruye(cb_tipoConstructor.itemindex);
    tipoReparacion:=TTipoReparacion(CB_Reparacion.itemIndex);
    case construye of
      ccCarpintero:
        begin
          HerramientaRequerida:=ihSerrucho;
          recursoX[0]:=orMadera;
          recursoX[1]:=orMaderaMagica;
          recursoX[2]:=orCuerda;
        end;
      ccGranCarpintero:
        begin
          HerramientaRequerida:=ihSerrucho;
          recursoX[0]:=orMadera;
          recursoX[1]:=orCuerda;
          recursoX[2]:=orCabezaAriete;
        end;
      ccCarpinteroArmero:
        begin
          HerramientaRequerida:=ihSerrucho;
          recursoX[0]:=orMadera;
          recursoX[1]:=orMaderaMagica;
          recursoX[2]:=orUmbo;
        end;
      ccHerrero:
        begin
          HerramientaRequerida:=ihMartillo;
          recursoX[0]:=orMango;
          recursoX[1]:=orLingoteHierro;
          recursoX[2]:=orLingoteArcanita;
        end;
      ccGranHerrero:
        begin
          HerramientaRequerida:=ihMartillo;
          recursoX[0]:=orLingoteArcanita;
          recursoX[1]:=orLingotePlata;
          recursoX[2]:=orLingoteOro;
        end;
      ccAlquimista:
        begin
          HerramientaRequerida:=ihLibroAlquimia;
          recursoX[0]:=orMaderaMagica;
          recursoX[1]:=orLingotePlata;
          recursoX[2]:=orGemaInicial;
        end;
      ccGranAlquimista:
        begin
          HerramientaRequerida:=ihLibroAlquimia;
          recursoX[0]:=orLingotePlata;
          recursoX[1]:=orLingoteOro;
          recursoX[2]:=orGemaInicial;
        end;
      ccSastre:
        begin
          HerramientaRequerida:=ihTijeras;
          recursoX[0]:=orTela;
          recursoX[1]:=orCuero;
          recursoX[2]:=orFibras;
        end;
      ccGranSastre:
        begin
          HerramientaRequerida:=ihTijeras;
          recursoX[0]:=orMizril;
          recursoX[1]:=orCueroDragon;
          recursoX[2]:=orGemaInicial;
        end;
      ccHerbalista:
        begin
          HerramientaRequerida:=ihCalderoMagico;
          recursoX[0]:=orIngredienteInicial;
          recursoX[1]:=orIngredienteInicial;
          recursoX[2]:=orIngredienteInicial;
        end;
      else
        begin
          construye:=ccNoSeConstruye;
          HerramientaRequerida:=$00;
          for i:=0 to 2 do
          begin
            cantidadX[i]:=0;
            recursoX[i]:=0;
          end;
          NivelConstructor:=0;
          CantidadConstruida:=0;
          exit;
        end;
    end;
    NivelConstructor:=valor(e_nivelConst.text,1,80);
    for i:=0 to 2 do
      if recursoX[i]=orIngredienteInicial then
      begin
        inc(recursoX[i],cantidadX[i] and $7);
        if ((cantidadX[i]>0) or (i=0)) then
          cantidadX[i]:=1;
      end;
    if recursoX[2]=orGemaInicial then
    begin
      inc(recursoX[2],cantidadX[2] and $7);//Modificador=gema.
      if cantidadX[2]>0 then
        cantidadX[2]:=1;
    end;
  end;
end;

procedure TForm1.GuardarClick(Sender: TObject);
var f:file of TArchivoObjetos;
    i,total,cantidad,costo1,costo2,costo3:integer;
    artefactoAux:Tartefacto;
begin
  if MessageDlg('Al guardar modificaciones haces el archivo incompatible'+#13+
    'con la versión estándar y necesitarás distribuir el archivo obj.b'+#13+
    'a todos los que quieran ingresar a tu servidor de juego.',
    mtConfirmation,mbOKCancel,0)<>mrOk then exit;
  AlaLista;
  LimpiarCadenasClick(nil);
  GuardarInfo;
// Control de precios:
// El costo total de materiales debe ser la mitad del costo del
//artefacto o menor.
  for i:=0 to 255 do
  with Info,datos[i] do
  begin
    if construye>ccNoSeConstruye then
    begin
      costo1:=datos[recursoX[0]].costo;
      costo2:=datos[recursoX[1]].costo;
      costo3:=datos[recursoX[2]].costo;
      if (recursoX[2]>=orGemaInicial) and (recursoX[2]<=orGemaFinal) then
        costo3:=costo3*25;
      total:=(costo1*cantidadX[0]+costo2*cantidadX[1]+costo3*cantidadX[2]);
      case construye of
        ccGranHerrero,ccGranAlquimista,ccGranSastre:total:=total*2;
        else
          total:=(total*5) div 2;
      end;
      ArtefactoAux.id:=i;
      ArtefactoAux.modificador:=CantidadConstruida;
      cantidad:=NumeroElementos(artefactoAux);
      //Excepcion: Para objetos consumibles:
      if (artefactoAux.id shr 3)=17 then
        cantidad:=artefactoAux.Modificador;
      if cantidad>1 then
        total:=total div cantidad;
      if total<>costo then
      begin
        showmessage(nombre[i]+' Costo real: '+inttostr(total)+' costo: '+inttostr(costo));
        costo:=total;
      end;
    end;
//    TipoAnimacion:=0;
  end;
//     Info.CheckSum:=Criptico(Info.Datos,sizeof(Info.Datos));
  assignFile(f,Nombre_Archivo);
  reWrite(f);
  write(f,Info);
  closeFile(f);
//     DeCriptico(Info.Datos,sizeof(Info.Datos));
end;

procedure TForm1.LimpiarCadenasClick(Sender: TObject);
var i:integer;
    s:string;
begin
  with info do
  for i:=0 to 255 do
  begin
    s:=nombre[i];
    fillchar(nombre[i],sizeof(nombre[i]),#0);
    nombre[i]:=s;
  end;
  LlenarNombresClaseActualEnElGrid;
end;

procedure TForm1.AlaLista;
var i:integer;
begin
  with Info do
    for i:=0 to 7 do
      nombre[i+clase*8]:=SG_Nombres.Cells[i div 4,i mod 4];
end;

procedure TForm1.LlenarNombresClaseActualEnElGrid;
var i:integer;
begin
  with Info do
    for i:=0 to 7 do
      SG_Nombres.Cells[i div 4,i mod 4]:=nombre[i+clase*8];
end;

procedure TForm1.CB_ClaseChange(Sender: TObject);
begin
  clase:=CB_Clase.ItemIndex;
  LlenarNombresClaseActualEnElGrid;
  MostrarInfo;
end;

procedure TForm1.CB_ClaseEnter(Sender: TObject);
begin
  AlaLista;
end;

procedure TForm1.SG_NombresSelectCell(Sender: TObject; Col, Row: Integer;
  var CanSelect: Boolean);
begin
  tipo:=Row+col*4;
  MostrarInfo;
end;

procedure TForm1.GuardarInfo;
var inf:TDescriptorObjeto;
    claseAnterior:integer;
begin
  if CodigoAnterior<0 then exit;
  //Si se modifico algo antes => guardarlo
  inf.costo:=valor(E_mo.text,0,650)*100+valor(E_mp.text,0,99);
  claseAnterior:=CodigoAnterior shr 3;
  if claseAnterior=1 then
    inf.modificadorADC:=valor(E_ModADC.text,50,80)
  else
    if claseAnterior<=6 then
      inf.modificadorADC:=valor(E_ModADC.text,-25,15)
    else
      if claseAnterior<=12 then
        inf.modificadorADC:=valor(E_ModADC.text,-25,25)
      else
        inf.modificadorADC:=valor(E_ModADC.text,0,100);
  with inf do
  if MostrarComoArma(CodigoAnterior) then //armas
  begin
    if (CodigoAnterior shr 3)=1 then
    begin
      danno1B:=valor(D1_base.text,0,45);
      danno1P:=valor(D1_plus.text,danno1B,60)+1-danno1B;
      danno2B:=valor(D2_base.text,0,45);
      danno2P:=valor(D2_plus.text,danno2B,60)+1-danno2B;
    end
    else
    begin
      danno1B:=valor(D1_base.text,0,6);
      danno1P:=valor(D1_plus.text,danno1B,18)+1-danno1B;
      danno2B:=valor(D2_base.text,0,6);
      danno2P:=valor(D2_plus.text,danno2B,18)+1-danno2B;
    end
  end
  else
  begin
     danno1B:=valor(E_punz.text,0,4);
     danno1P:=valor(E_cort.text,0,4);
     danno2B:=valor(E_golp.text,0,4);
     danno2P:=valor(E_magi.text,0,4);
  end;
  inf.RazasNoPermitidas:=$00;
  if CheckBox1.Checked then inf.RazasNoPermitidas:=inf.RazasNoPermitidas or $01;
  if CheckBox2.Checked then inf.RazasNoPermitidas:=inf.RazasNoPermitidas or $02;
  if CheckBox3.Checked then inf.RazasNoPermitidas:=inf.RazasNoPermitidas or $04;
  if CheckBox4.Checked then inf.RazasNoPermitidas:=inf.RazasNoPermitidas or $08;
  if CheckBox5.Checked then inf.RazasNoPermitidas:=inf.RazasNoPermitidas or $10;
  if CheckBox6.Checked then inf.RazasNoPermitidas:=inf.RazasNoPermitidas or $20;
  if CheckBox7.Checked then inf.RazasNoPermitidas:=inf.RazasNoPermitidas or $40;
  if CheckBox8.Checked then inf.RazasNoPermitidas:=inf.RazasNoPermitidas or $80;
  inf.clasesNoPermitidas:=$00;
  if CheckBox9.Checked then inf.clasesNoPermitidas:=inf.clasesNoPermitidas or $01;
  if CheckBox10.Checked then inf.clasesNoPermitidas:=inf.clasesNoPermitidas or $02;
  if CheckBox11.Checked then inf.clasesNoPermitidas:=inf.clasesNoPermitidas or $04;
  if CheckBox12.Checked then inf.clasesNoPermitidas:=inf.clasesNoPermitidas or $08;
  if CheckBox13.Checked then inf.clasesNoPermitidas:=inf.clasesNoPermitidas or $10;
  if CheckBox14.Checked then inf.clasesNoPermitidas:=inf.clasesNoPermitidas or $20;
  if CheckBox15.Checked then inf.clasesNoPermitidas:=inf.clasesNoPermitidas or $40;
  if CheckBox16.Checked then inf.clasesNoPermitidas:=inf.clasesNoPermitidas or $80;
  GuardarInformacionConstruccion(inf,CodigoAnterior);
  inf.NivelMinimo:=valor(E_nivelMinimo.text,1,25);
  if (CodigoAnterior shr 3)=5 then
    inf.AlcanceArma:=aaRango
  else
    if (((CodigoAnterior shr 3)>=1) and ((CodigoAnterior shr 3)<=4)) or (CodigoAnterior<=1) then
      inf.AlcanceArma:=aaMelee
    else
      if (CodigoAnterior shr 3=14) then
        inf.AlcanceArma:=aaMagica
      else
        inf.AlcanceArma:=aaNoEsArma;
  if inf.AlcanceArma=aaNoEsArma then
  begin
    inf.pesoArma:=paNoEsArma;
    inf.TipoAnimacion:=taaNinguno;
    if MostrarComoArma(CodigoAnterior) then
      inf.tipoArma:=taPunzante//Municiones
    else
      inf.tipoArma:=taNoEsArma;
  end
  else
  begin
    inf.pesoArma:=TPesoArma(cb_peso.itemindex);
    inf.tipoArma:=TTipoArma(cb_tipo.itemindex);
    inf.TipoAnimacion:=TTipoAnimacionArma(cb_animacion.itemindex);
  end;
  Info.datos[CodigoAnterior]:=inf;
end;

procedure TForm1.MostrarInfo;
var des:TDescriptorObjeto;
begin
  //Introducir Códigos.
  GuardarInfo;
  codigoAnterior:=clase*8+tipo;
  des:=Info.datos[CodigoAnterior];
  case codigoAnterior shr 3 of
    2..5,7..12:LBDescripcion.caption:='Objeto hechizable';
    6,18,19:LBDescripcion.caption:='Objeto envenenable';
    else LBDescripcion.caption:=''
  end;
  if (des.TipoArma<>taMagia) then
    GB_Arma.caption:='Arma:'
  else
    GB_Arma.caption:='Arma mágica:(Daño Base Conjuro * Daño Arma / 2)';
  E_mo.text:=inttostr(des.costo div 100);
  E_mp.text:=inttostr(des.costo mod 100);
  E_ModADC.text:=inttostr(des.modificadorADC);
  if MostrarComoArma(codigoAnterior) then //armas
  begin
    Lb_rango.Caption:=DescribirAlcanceArma(des.AlcanceArma);
    if codigoAnterior shr 3=1 then
      LB_Modificador.Caption:='Bono por a.mágica [50..80]'
    else
      LB_Modificador.Caption:='Penalización/Bono [-25..15]';
    GB_arma.show;
    GB_armadura.hide;
    d1_base.text:=inttostr(des.danno1B);
    d1_plus.text:=inttostr(des.danno1P+des.danno1B-1);
    d2_base.text:=inttostr(des.danno2B);
    d2_plus.text:=inttostr(des.danno2P+des.danno2B-1);
    cb_peso.itemIndex:=integer(des.pesoArma);
    cb_tipo.itemIndex:=integer(des.tipoArma);
    cb_animacion.itemIndex:=integer(des.TipoAnimacion);
  end
  else
  begin//no son armas
    Lb_rango.Caption:='';
    GB_arma.hide;
    if EsIdDeArmadura(codigoAnterior) then//Estos objetos pueden ser armaduras
    begin
      LB_Modificador.Caption:='Penalización/Bono [-25..25] ';
      GB_armadura.show;
      e_punz.text:=inttostr(des.danno1B);
      e_cort.text:=inttostr(des.danno1P);
      e_golp.text:=inttostr(des.danno2B);
      e_magi.text:=inttostr(des.danno2P);
    end
    else
    begin
      LB_Modificador.Caption:='Modificador [0..100] ';
      GB_armadura.hide;
      e_punz.text:='0';
      e_cort.text:='0';
      e_golp.text:='0';
      e_magi.text:='0';
    end;
    cb_peso.itemIndex:=0;
    cb_tipo.itemIndex:=0;
    cb_animacion.itemIndex:=0;
  end;
  CheckBox1.Checked:=Boolean(des.RazasNoPermitidas and $01);
  CheckBox2.Checked:=Boolean(des.RazasNoPermitidas and $02);
  CheckBox3.Checked:=Boolean(des.RazasNoPermitidas and $04);
  CheckBox4.Checked:=Boolean(des.RazasNoPermitidas and $08);
  CheckBox5.Checked:=Boolean(des.RazasNoPermitidas and $10);
  CheckBox6.Checked:=Boolean(des.RazasNoPermitidas and $20);
  CheckBox7.Checked:=Boolean(des.RazasNoPermitidas and $40);
  CheckBox8.Checked:=Boolean(des.RazasNoPermitidas and $80);
  CheckBox9.Checked:=Boolean(des.clasesNoPermitidas and $01);
  CheckBox10.Checked:=Boolean(des.clasesNoPermitidas and $02);
  CheckBox11.Checked:=Boolean(des.clasesNoPermitidas and $04);
  CheckBox12.Checked:=Boolean(des.clasesNoPermitidas and $08);
  CheckBox13.Checked:=Boolean(des.clasesNoPermitidas and $10);
  CheckBox14.Checked:=Boolean(des.clasesNoPermitidas and $20);
  CheckBox15.Checked:=Boolean(des.clasesNoPermitidas and $40);
  CheckBox16.Checked:=Boolean(des.clasesNoPermitidas and $80);
  cb_tipoConstructor.itemIndex:=integer(des.construye);
  CB_Reparacion.itemIndex:=integer(des.tipoReparacion);
  CB_TipoconstructorChange(nil);
  if ((des.recursoX[0]>=orIngredienteInicial) and (des.recursoX[0]<=orIngredienteFinal)) then
    E_recurso1.text:=inttostr(des.recursoX[0] and $7)
  else
    E_recurso1.text:=inttostr(des.cantidadX[0]);

  if ((des.recursoX[1]>=orIngredienteInicial) and (des.recursoX[1]<=orIngredienteFinal)) then
    E_recurso2.text:=inttostr(des.recursoX[1] and $7)
  else
    E_recurso2.text:=inttostr(des.cantidadX[1]);

  if ((des.recursoX[2]>=orGemaInicial) and (des.recursoX[2]<=orGemaFinal)) or
     ((des.recursoX[2]>=orIngredienteInicial) and (des.recursoX[2]<=orIngredienteFinal)) then
    E_recurso3.text:=inttostr(des.recursoX[2] and $7)
  else
    E_recurso3.text:=inttostr(des.cantidadX[2]);
  E_Cantidad.text:=inttostr(des.cantidadConstruida);
  E_nivelConst.text:=inttostr(des.NivelConstructor);
  E_nivelMinimo.text:=inttostr(des.NivelMinimo);

  LbCodigo.caption:=inttostr(codigoAnterior)+' , ('+inttostr(clase)+'/'+inttostr(tipo)+')';
  PaintBox.repaint;
end;

procedure TForm1.BtAbrirClick(Sender: TObject);
var f:file of TArchivoObjetos;
begin
    CB_Clase.ItemIndex:=0;
    clase:=0;
    SG_nombres.Col:=0;
    SG_nombres.Row:=0;

    assignFile(f,Nombre_Archivo);
    fileMode:=0;
    reset(f);
    read(f,Info);
    closeFile(f);

    LlenarNombresClaseActualEnElGrid;
    tipo:=0;
    clase:=0;
    CodigoAnterior:=-1;
    MostrarInfo;
end;

function TForm1.valor(const cdn:string;const inf,sup:integer):integer;
var code:integer;
begin
     val(cdn,result,code);
     if code<>0 then
       if inf<0 then result:=0 else result:=inf;
     if result<inf then result:=inf;
     if result>sup then result:=sup;
end;

function TForm1.controlar(const cdn:string;const inf,sup:integer):string;
begin
  result:=inttostr(valor(cdn,inf,sup));
end;

procedure TForm1.E_MOExit(Sender: TObject);
begin
  E_mo.text:=controlar(E_mo.text,0,650);
end;

procedure TForm1.E_MPExit(Sender: TObject);
begin
  E_mp.text:=controlar(E_mp.text,0,99);
end;

procedure TForm1.E_nivelConstExit(Sender: TObject);
begin
  if sender is TEdit then
    with TEdit(Sender) do
      text:=controlar(text,1,80);
end;

procedure TForm1.E_ModADCExit(Sender: TObject);
begin
  if CB_clase.ItemIndex=1 then
    E_ModADC.text:=controlar(E_ModADC.text,50,80)
  else
    if CB_clase.ItemIndex<=6 then
      E_ModADC.text:=controlar(E_ModADC.text,-25,15)
    else
      if CB_clase.ItemIndex<=12 then
        E_ModADC.text:=controlar(E_ModADC.text,-25,25)
      else
        E_ModADC.text:=controlar(E_ModADC.text,0,100);
end;

procedure TForm1.E_TipoDannoExit(Sender: TObject);
begin
if sender is TEdit then
  with TEdit(Sender) do
   text:=controlar(text,0,4);
end;

procedure TForm1.D_baseExit(Sender: TObject);
begin
if sender is TEdit then
  with TEdit(Sender) do
    if CB_clase.ItemIndex=1 then
      text:=controlar(text,0,45)
    else
      text:=controlar(text,0,6);
end;

procedure TForm1.d_plusExit(Sender: TObject);
begin
if sender is TEdit then
  with TEdit(Sender) do
    if CB_clase.ItemIndex=1 then
      text:=controlar(text,0,60)
    else
      text:=controlar(text,0,18);
end;

procedure TForm1.recursoExit(Sender: TObject);
begin
if sender is TEdit then
  with TEdit(Sender) do
    text:=controlar(text,0,250);
end;

procedure TForm1.CB_TipoconstructorChange(Sender: TObject);
var mostrarControles:bytebool;
begin
  mostrarControles:=CB_TipoConstructor.itemindex<>0;
  case CB_TipoConstructor.itemindex of
    1:begin//Herrero
      Lb_Recurso1.caption:='Mango:';
      Lb_Recurso2.caption:='Hierro:';
      Lb_Recurso3.caption:='Arcanita:';
    end;
    2:begin//Gran Herrero
      Lb_Recurso1.caption:='Arcanita:';
      Lb_Recurso2.caption:='Plata:';
      Lb_Recurso3.caption:='Oro:';
    end;
    3:begin//Alquimista
      Lb_Recurso1.caption:='Madera Mágica:';
      Lb_Recurso2.caption:='Plata:';
      Lb_Recurso3.caption:='Gema:';
    end;
    4:begin//Gran Alquimista
      Lb_Recurso1.caption:='Plata:';
      Lb_Recurso2.caption:='Oro:';
      Lb_Recurso3.caption:='Gema:';
    end;
    5:begin//Sastre
      Lb_Recurso1.caption:='Tela:';
      Lb_Recurso2.caption:='Cuero:';
      Lb_Recurso3.caption:='Fibras:';
    end;
    6:begin//Gran Sastre
      Lb_Recurso1.caption:='Mizril:';
      Lb_Recurso2.caption:='Cuero de Dragón:';
      Lb_Recurso3.caption:='Gema:';
    end;
    7:begin//Carpintero Armero
      Lb_Recurso1.caption:='Madera:';
      Lb_Recurso2.caption:='Madera mágica';
      Lb_Recurso3.caption:='Umbo (Rodela):';
    end;
    8:begin//herbalista
      Lb_Recurso1.caption:='Ingrediente:';
      Lb_Recurso2.caption:='Ingrediente:';
      Lb_Recurso3.caption:='Ingrediente:';
    end;
    9:begin//Carpintero
      Lb_Recurso1.caption:='Madera:';
      Lb_Recurso2.caption:='Madera mágica:';
      Lb_Recurso3.caption:='Cuerda:';
    end;
    10:begin//Gran Carpintero
      Lb_Recurso1.caption:='Madera:';
      Lb_Recurso2.caption:='Cuerda:';
      Lb_Recurso3.caption:='Cabeza de ariete:';
    end;
    else
    begin
      e_recurso1.Text:='0';
      e_recurso2.Text:='0';
      e_recurso3.Text:='0';
      E_nivelConst.Text:='1';
    end;
  end;
  LB_cantidad.visible:=mostrarControles;
  Lb_NivelConst.visible:=mostrarControles;
  E_nivelConst.visible:=mostrarControles;
  E_Cantidad.visible:=mostrarControles;
  Lb_Recursos.visible:=mostrarControles;
  Lb_recurso1.visible:=mostrarControles;
  Lb_recurso2.visible:=mostrarControles;
  Lb_recurso3.visible:=mostrarControles;
  E_recurso1.visible:=mostrarControles;
  E_recurso2.visible:=mostrarControles;
  E_recurso3.visible:=mostrarControles;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  BtAbrirClick(nil);
end;

procedure TForm1.FormCreate(Sender: TObject);
var jpg:TjpegImage;
begin
  CarpetaPrincipal:=ExtractFileDir(Application.ExeName);
  ControlStyle:=ControlStyle+[csOpaque];
  with PaintBox do
    ControlStyle:=ControlStyle+[csOpaque];
  jpg:=TjpegImage.Create;
  try
    jpg.LoadFromFile(Nombre_A_Objetos);
  except
    showmessage('Este programa debe estar ubicado en la carpeta "Editores"');
    jpg.free;
    Halt;
    exit;
  end;
  Graficos:=Tbitmap.Create;
  Graficos.Assign(jpg);
  jpg.free;
  caption:=caption+GetVersion;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Graficos.free;
end;

procedure TForm1.PaintBoxPaint(Sender: TObject);
var id:integer;
begin
  id:=clase*8+tipo;
  BitBlt(PaintBox.Canvas.handle,0,0,40,40,Graficos.canvas.handle,
    (id and $7)*40,(id shr 3)*40,SRCCOPY);
end;

function TForm1.DescribirAlcanceArma(Alcance:TAlcanceArma):string;
begin
  if Alcance=aaRango then
    result:='Rango'
  else
    if Alcance=aaMelee then
      result:='Meleé'
    else
      if Alcance=aaMagica then
        result:='Mágica'
      else
        result:='Munición';
end;

function TForm1.MostrarComoArma(idObjeto:byte):boolean;
begin
  result:=(idObjeto<=1)or ((idObjeto>=8)and(idObjeto<=55))
  or((idObjeto>=112)and(idObjeto<=114)) or ((idObjeto>=116)and(idObjeto<=118));
end;

procedure TForm1.Salir1Click(Sender: TObject);
begin
  close;
end;

function ModAtaque(modGac0:integer):string;
begin
  if modGac0<>0 then
  begin
    result:=inttostr(modGac0);
    if modGac0>0 then result:='+'+result;
    result:=result+'%';
  end
  else
    result:='---';
end;

function MostrarNivel(nivel:byte):string;
begin
  if nivel>1 then result:=intastr(nivel) else result:='---'
end;

procedure TForm1.Crearmanualdearmas1Click(Sender: TObject);
var f:textFile;
    i:integer;
  function NombreArma(indice:byte):string;
  begin
    if indice>2 then result:=info.nombre[indice] else
    if indice=0 then result:='Puño derecho' else result:='Puño izquierdo'
  end;
begin
//crear carpeta para iconos
  CreateDir(CarpetaPrincipal+'\icob');

  assignFile(f,'LasArmas.html');
  rewrite(f);
  writeln(f,'<center><h1>Armas</h1><table border=1 cellpadding=4 cellspacing=0>');
  writeln(f,'<tr><th colspan=2>Nombre</th><th>Daño<BR>PM</th><th>Daño<BR>G</th><th>Tipo<BR>de daño</th><th>Peso</th>'+
  {'<th>Clases</th><th>Razas</th>}'<th>Mod. de<BR>Ataque</th><th>Nivel del<BR>Avatar</th></tr>');
  for i:=0 to 55 do
  with Info,datos[i] do
  begin
    if (i<2) or (i>=16) then
    if MostrarComoArma(i) then
    begin
      crearIcono(i);
      writeln(f,'<tr><td bgcolor=#000000><img align=middle src="icob/'+inttostr(i)+extension_GRF+'"></img></td><td>'+nombreArma(i)+
      '</td><td>'+NivelDanno(danno1b,danno1p)+
      '</td><td>'+NivelDanno(danno2b,danno2p)+'</td><td>'+cb_Tipo.Items[ord(TipoArma)]+
      '</td><td>'+cb_peso.items[ord(PesoArma)]+
      '</td><td>'+ModAtaque(modificadorADC)+
      '</td><td>'+MostrarNivel(nivelminimo)+'</td></tr>');
    end;
  end;
  writeln(f,'</table></center>');
  closefile(f);
end;

procedure TForm1.Crearmanualdearmasconjuradas1Click(Sender: TObject);
const TipoConjuro:array[0..1] of string=('Arcana','Sagrada');
var f:textFile;
    i:integer;
begin
//crear carpeta para iconos
  CreateDir(CarpetaPrincipal+'\icob');

  assignFile(f,'LasArmasConjurables.html');
  rewrite(f);
  writeln(f,'<center><h1>Armas Conjurables</h1><table border=1 cellpadding=4 cellspacing=0>');
  writeln(f,'<tr><th colspan=2>Nombre</th><th>Gema</th><th>Daño<BR>PM</th><th>Daño<BR>G</th><th>Tipo<BR>de daño</th>'+
  {'<th>Clases</th><th>Razas</th>}'<th>Mod. de<BR>Ataque</th><th>Peso<BR>Arma</th><th>Nivel<BR>Avatar</th></tr>');
  for i:=8 to 15 do
  with Info,datos[i] do
  begin
    if MostrarComoArma(i) then
    begin
      crearIcono(i);
      writeln(f,'<tr><td bgcolor=#000000><img align=middle src="icob/'+inttostr(i)+extension_GRF+'"></img></td><td>'+info.nombre[i]+'</td><td>'+info.nombre[i+orGemaInicial-8]+
      '</td><td>'+NivelDanno(danno1b,danno1p)+
      '</td><td>'+NivelDanno(danno2b,danno2p)+'</td><td>'+cb_Tipo.Items[ord(TipoArma)]+
      '</td><td>'+ModAtaque(modificadorADC)+'</td><td>'+cb_peso.items[ord(PesoArma)]+
      '</td><td>'+MostrarNivel(nivelminimo)+'</td></tr>');
    end;
  end;
  writeln(f,'</table></center>');
  closefile(f);
end;

function NivelArmadura(nivel:byte):string;
begin
  if nivel=0 then
    result:='---'
  else
  begin
    str(nivel*100/(nivel+4):0:0,result);
    result:=result+'%';
  end;
end;


procedure TForm1.Crearmanualdearmadurasvestimentas1Click(Sender: TObject);
var f:textFile;
    i:integer;
  function NombreArma(indice:byte):string;
  begin
    if indice>2 then result:=info.nombre[indice] else
    if indice=0 then result:='Puño derecho' else result:='Puño izquierdo'
  end;
begin
//crear carpeta para iconos
  CreateDir(CarpetaPrincipal+'\icob');

  assignFile(f,'LasArmaduras.html');
  rewrite(f);
  writeln(f,'<center><h1>Armaduras y Vestimentas</h1><table border=1 cellpadding=4 cellspacing=0>');
  writeln(f,'<tr><th rowspan=2 colspan=2>Nombre</th><th colspan=4>Reducción de daño</th><th rowspan=2>Mod. de<BR>Defensa</th><th rowspan=2>Nivel del<BR>Avatar</th></tr>');
  writeln(f,'<tr><th>Punzante</th><th>Cortante</th><th>Contun.</th><th>*Otros</th></tr>');
  for i:=56 to 97 do
  with Info,datos[i] do
  begin
    if (i>=56) and (i<=97) then//Armaduras y vestimentas
    begin
      writeln(f,'<tr><td bgcolor=#000000><img align=middle src="icob/'+inttostr(i)+extension_GRF+'"></img></td><td>'+nombreArma(i)+
      '</td><td>'+NivelArmadura(danno1b)+
      '</td><td>'+NivelArmadura(danno1p)+
      '</td><td>'+NivelArmadura(danno2b)+
      '</td><td>'+NivelArmadura(danno2p)+
      '</td><td>'+ModAtaque(modificadorADC)+
      '</td><td>'+MostrarNivel(nivelminimo)+'</td></tr>');
      crearIcono(i);
    end;
  end;
  writeln(f,'</table>');
  writeln(f,'*(fuego, hielo, rayo y veneno)</center>');
  closefile(f);
end;

procedure TForm1.E_MPChange(Sender: TObject);
begin
  LbCostoMp.caption:='('+intastr(valor(E_mp.text,0,MAXLONG)+valor(E_mo.text,0,MAXLONG)*100)+' mp)';
end;

procedure TForm1.Crearlistadeiconos1Click(Sender: TObject);
var i:integer;
begin
  for i:=0 to 63 do crearIcono(i);
end;

end.

