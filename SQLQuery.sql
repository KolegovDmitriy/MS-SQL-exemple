ALTER FUNCTION _FormSclad(
    @Key_TMC int
  )
  -- ������� �������� ��� 3 ���������, ��� ������� �� ��������� 2 ������ �� ������� ����
 RETURNS @return TABLE
  (
    TMC_Key INT  
   ,CountTMC INT  
 --,DateZakupki DATE
  )
AS
BEGIN
 Declare @TMC_Key int
 Declare @CountTMC int
   
 SELECT  @TMC_Key = ���.����
        ,@CountTMC = �������.����������
     -- ,DateZakupki = 
                   
    FROM ���
      JOIN ������� on ���.���� = �������.[�������� 1]
      JOIN [��� ���] on ���.��� = [��� ���].���� 
  WHERE ([��� ���]._���������� = 0) and (���.���� = @Key_TMC)   
   
  Set @TMC_Key=ISNULL(@TMC_Key,0)
  Set @CountTMC=ISNULL(@CountTMC,0)
--Set KeyTMC=ISNULL(KeyTMC,0)   
     
  insert into @return(TMC_Key,CountTMC) values ( @TMC_Key, @CountTMC )

  return 
   
END

---------------------------------------------------------

ALTER FUNCTION _FormSclad(
    @Key_TMC int
  )
  -- ������� �������� ��� 3 ���������, ��� ������� �� ��������� 2 ������ �� ������� ����
 RETURNS @return TABLE
  (
    TMC_Key INT  
   ,CountTMC INT  
 --,DateZakupki DATE
  )
AS
BEGIN
 Declare @TMC_Key int
 Declare @CountTMC int
   
 SELECT  @TMC_Key = ���.����
        ,@CountTMC = �������.����������
     -- ,DateZakupki = 
                   
    FROM ���
      JOIN ������� on ���.���� = �������.[�������� 1]
      JOIN [��� ���] on ���.��� = [��� ���].���� 
  WHERE ([��� ���]._���������� = 0) and (���.���� = @Key_TMC)   
   
  Set @TMC_Key=ISNULL(@TMC_Key,0)
  Set @CountTMC=ISNULL(@CountTMC,0)
--Set KeyTMC=ISNULL(KeyTMC,0)   
     
  insert into @return(TMC_Key,CountTMC) values ( @TMC_Key, @CountTMC )

  return 
   
END

-------------------------------------------------------------------

lter function kolichestvo_plenok(
  @i_Dat INT	-- ������������ ����� (�������)
 ,@i_NoDat INT  -- �������������� ����� (�������)
 ,@i_Color INT  -- �����������
 ,@i_Size INT	-- ���� ������� _������������������������ (3 - 15x21)
)

RETURNS int

as 
BEGIN
	-- �������� ������� �����
	Set @i_Size=ISNULL(@i_Size,0)
	IF @i_Size=0 RETURN 0

	-- ���-�� ������ � �������
	Declare @i_shtamp INT  
	Declare @i_pl INT

	SELECT @i_pl = ������������ 
		From _������������������������ 
			Where ���� = @i_Size

	Declare @dTemp Money
	
	Set  @dTemp=@i_Dat
	Set  @dTemp=ceiling(@dTemp/@i_pl)

	SET @i_shtamp=0
	
	IF @i_NoDat > 0 SET @i_shtamp = 2*@i_Color
	IF @i_Dat > 0 SET @i_shtamp = @i_shtamp + @dTemp * 2 * @i_Color

	return @i_shtamp

end 

----------------------------------------------------------------------

declare @���������_������_tab table( sale_id int );
declare @���������_������ INT
Set @���������_������ = 54 
insert into @���������_������_tab ( sale_id  ) values(7998529);

declare grafik_cursor cursor local forward_only for
select sale_id from @���������_������_tab

declare @sale_id int

Open grafik_cursor;
Fetch from grafik_cursor Into @sale_id;

While @@FETCH_STATUS = 0
   begin
     print @sale_id
       if ([dbo].[_�������_�������_��_������]( @sale_id )=0 )
            begin
              update  [�������] set [�������].[_����] = @���������_������
              from  [�������]
			     where
			     [�������].����=@sale_id;
			   exec dbo._�������_��������_������_��_������������
			   @in__����_�������101��� = @sale_id ,
			   @in__NameValueStr=''; -- ��� ������ ���� ���������� ��������������
			end;
      Fetch next from grafik_cursor Into @sale_id; 
   end
   
close grafik_cursor
deallocate grafik_cursor

-----------------------------------------------------------------------------

ALTER FUNCTION [dbo].[_IE_FindPaper]
(
 @i_Size INT				    ----- ���� ������� _������������������������ 
,@paper_bl INT 				    ----- ���� ������� _��������������������� 
,@BlockOrFN BIT                 ----- 0 - ����� ������ ��� �����, 1 - ����� ������ ��� ������� �������
)

RETURNS nvarchar(50)

as 
BEGIN
	
 Declare @is_roll BIT
 Declare @xPaperBl INT
 Declare @yPaperBl INT
 Declare @dRoll INT
 Declare @TMSPaper INT
 Declare @TMS_Density INT
 Declare @xPaperTMS INT
 Declare @yPaperTMS INT
 Declare @xPaperFN INT
 Declare @yPaperFN INT
 Declare @NamePaper nvarchar(50)
  
	SELECT @is_roll = [�������],
		 @xPaperBl = [������������],
		 @yPaperBl = [�����������],
		 @xPaperFN = [��������������], 
		 @yPaperFN = [�������������],
		 @dRoll = [����������]		   
	  FROM [_������������������������] 
	  Where ����=@i_Size
	  
-- ������� ������ �� �����	  
	If @is_roll=0
	Begin
	
		SELECT  Top 1  @TMSPaper=���,
					   @xPaperTMS=_������,   
					   @yPaperTMS=_�����					     
		FROM [_��������������]
			Left JOIN [���] With (NoLock)  On [���].����=_��������������.���
			Left JOIN _��������������������� On _���������������������.����=_��������������.�����������
		Where �����������=@paper_bl
			  and �����=@is_roll
			  and _������>=@xPaperBl
		      and _�����>=@yPaperBl
		order By (���._������*���._�����) Asc

		Set @TMSPaper=ISNULL(@TMSPaper,0) 
	             	
     END -- if @is_roll = 0 begin
  
-- ������� ������ ����   
	If @is_roll=1
	Begin

		SELECT  Top 1  
				@TMSPaper=���,
				@xPaperTMS=_������  
		FROM [_��������������]
				Left JOIN [���] With (NoLock)  On [���].����=_��������������.���
				Left JOIN _��������������������� On _���������������������.����=_��������������.�����������
		Where �����������=@paper_bl
				and �����=@is_roll
				and _������>=@dRoll
		order By ���._������ Asc

		Set @TMSPaper=ISNULL(@TMSPaper,0) 
	End -- if @is_roll = 1 begin    
     
    Select @NamePaper = ���.�������� From ��� Where ���.���� = @TMSPaper    

	return @NamePaper
End

----------------------------------------------------------------------------------------

ALTER function [dbo].[_IE_FindPaper_name_bl_key]
(
 @_name_bl_key INT				    ----- ���� ������� _name_bl
 )

RETURNS nvarchar(50)

as 
BEGIN

	Declare @i_Size INT				    ----- ���� ������� _������������������������ 
	Declare @paper_bl INT               ----- ���� ������� _���������������������
	Declare @NamePaper nvarchar(50)
			     

    SELECT @i_Size =_������������������������.����,
           @paper_bl =_���������������������.����  
    FROM _name_bl
		join  _������������������������ on _������������������������.���� = _name_bl.�����������
		join  _��������������������� on _���������������������.���� = _name_bl.����������
	where _name_bl.���� = @_name_bl_key
   
    Select @NamePaper = [dbo].[_IE_FindPaper] (@i_Size, @paper_bl) 

	return @NamePaper
End

------------------------------------------------------------------------------------------

