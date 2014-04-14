(********************************************************
Author: Sergio Alex Chávez Rico
Operating System: 32-bit MS Windows (95/98/NT/2000/XP)
License: GNU General Public License (GPL)
Category: Multi-User Dungeons (MUD)
*********************************************************)
unit def_banderas;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TF_Banderas = class(TForm)
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox0: TCheckBox;
    Button1: TButton;
    Button3: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Banderas:byte;
    ListaCB:array[0..7] of TCheckBox;
    procedure showmodal(LasBanderas,inicial:byte); reintroduce;
  end;

var
  F_Banderas: TF_Banderas;

implementation
uses objetos;
{$R *.DFM}

procedure TF_Banderas.showmodal(LasBanderas,inicial:byte);
var i:integer;
begin
  Banderas:=LasBanderas;
  for i:=0 to 7 do
    with ListaCB[i] do
    begin
      Checked:=bytebool(banderas and (1 shl i));
      Caption:='Bandera '+intastr(inicial+i);
    end;
  inherited showmodal;
end;


procedure TF_Banderas.Button2Click(Sender: TObject);
begin
  close;
end;

procedure TF_Banderas.Button1Click(Sender: TObject);
var i:integer;
begin
  banderas:=0;
  for i:=0 to 7 do
    with ListaCB[i] do
      if Checked then banderas:=banderas or (1 shl i);
  close;
end;

procedure TF_Banderas.FormCreate(Sender: TObject);
begin
  ListaCB[0]:=CheckBox0;
  ListaCB[1]:=CheckBox1;
  ListaCB[2]:=CheckBox2;
  ListaCB[3]:=CheckBox3;
  ListaCB[4]:=CheckBox4;
  ListaCB[5]:=CheckBox5;
  ListaCB[6]:=CheckBox6;
  ListaCB[7]:=CheckBox7;
end;

procedure TF_Banderas.Button3Click(Sender: TObject);
var i:integer;
begin
  Banderas:=0;
  for i:=0 to 7 do
    with ListaCB[i] do
      Checked:=bytebool(banderas and (1 shl i));
end;

end.
