ALTER FUNCTION _FormSclad(
    @Key_TMC int
  )
  -- Функция отбирает ТМЦ 3 Договоров, для закупки за последние 2 месяца от текущей даты
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
   
 SELECT  @TMC_Key = ТМЦ.Ключ
        ,@CountTMC = Догспец.Количество
     -- ,DateZakupki = 
                   
    FROM ТМЦ
      JOIN Догспец on ТМЦ.Ключ = Догспец.[Субконто 1]
      JOIN [Вид ТМЦ] on ТМЦ.Вид = [Вид ТМЦ].Ключ 
  WHERE ([Вид ТМЦ]._ДелаетЛОГО = 0) and (ТМЦ.Ключ = @Key_TMC)   
   
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
  -- Функция отбирает ТМЦ 3 Договоров, для закупки за последние 2 месяца от текущей даты
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
   
 SELECT  @TMC_Key = ТМЦ.Ключ
        ,@CountTMC = Догспец.Количество
     -- ,DateZakupki = 
                   
    FROM ТМЦ
      JOIN Догспец on ТМЦ.Ключ = Догспец.[Субконто 1]
      JOIN [Вид ТМЦ] on ТМЦ.Вид = [Вид ТМЦ].Ключ 
  WHERE ([Вид ТМЦ]._ДелаетЛОГО = 0) and (ТМЦ.Ключ = @Key_TMC)   
   
  Set @TMC_Key=ISNULL(@TMC_Key,0)
  Set @CountTMC=ISNULL(@CountTMC,0)
--Set KeyTMC=ISNULL(KeyTMC,0)   
     
  insert into @return(TMC_Key,CountTMC) values ( @TMC_Key, @CountTMC )

  return 
   
END

-------------------------------------------------------------------

lter function kolichestvo_plenok(
  @i_Dat INT	-- Датированных полос (страниц)
 ,@i_NoDat INT  -- Недатированных полос (страниц)
 ,@i_Color INT  -- Красочность
 ,@i_Size INT	-- Ключ таблицы _СправочникРазмеровБлоков (3 - 15x21)
)

RETURNS int

as 
BEGIN
	-- Проверка размера блока
	Set @i_Size=ISNULL(@i_Size,0)
	IF @i_Size=0 RETURN 0

	-- кол-во пленок и штампов
	Declare @i_shtamp INT  
	Declare @i_pl INT

	SELECT @i_pl = ПолосПечЛист 
		From _СправочникРазмеровБлоков 
			Where Ключ = @i_Size

	Declare @dTemp Money
	
	Set  @dTemp=@i_Dat
	Set  @dTemp=ceiling(@dTemp/@i_pl)

	SET @i_shtamp=0
	
	IF @i_NoDat > 0 SET @i_shtamp = 2*@i_Color
	IF @i_Dat > 0 SET @i_shtamp = @i_shtamp + @dTemp * 2 * @i_Color

	return @i_shtamp

end 

----------------------------------------------------------------------

declare @выбранный_список_tab table( sale_id int );
declare @выбранный_шаблон INT
Set @выбранный_шаблон = 54 
insert into @выбранный_список_tab ( sale_id  ) values(7998529);

declare grafik_cursor cursor local forward_only for
select sale_id from @выбранный_список_tab

declare @sale_id int

Open grafik_cursor;
Fetch from grafik_cursor Into @sale_id;

While @@FETCH_STATUS = 0
   begin
     print @sale_id
       if ([dbo].[_шаблоны_построн_ли_график]( @sale_id )=0 )
            begin
              update  [Догспец] set [Догспец].[_Брак] = @выбранный_шаблон
              from  [Догспец]
			     where
			     [Догспец].Ключ=@sale_id;
			   exec dbo._шаблоны_добавить_шаблон_по_ключуДогспец
			   @in__Ключ_догспец101дог = @sale_id ,
			   @in__NameValueStr=''; -- тут должны быть включаемые персонализации
			end;
      Fetch next from grafik_cursor Into @sale_id; 
   end
   
close grafik_cursor
deallocate grafik_cursor

-----------------------------------------------------------------------------

ALTER FUNCTION [dbo].[_IE_FindPaper]
(
 @i_Size INT				    ----- Ключ таблицы _СправочникРазмеровБлоков 
,@paper_bl INT 				    ----- Ключ таблицы _СправочникБумагиБлока 
,@BlockOrFN BIT                 ----- 0 - Выбор бумаги для блока, 1 - Выбор бумаги для форзаца нарзаца
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
  
	SELECT @is_roll = [ЭтоРоль],
		 @xPaperBl = [БумагаШирина],
		 @yPaperBl = [БумагаДлина],
		 @xPaperFN = [БумагаШиринаФН], 
		 @yPaperFN = [БумагаДлинаФН],
		 @dRoll = [БумагаРоль]		   
	  FROM [_СправочникРазмеровБлоков] 
	  Where Ключ=@i_Size
	  
-- Выборка бумаги из флата	  
	If @is_roll=0
	Begin
	
		SELECT  Top 1  @TMSPaper=ТМЦ,
					   @xPaperTMS=_Ширина,   
					   @yPaperTMS=_Длина					     
		FROM [_БумагаБлокаТМЦ]
			Left JOIN [ТМЦ] With (NoLock)  On [ТМЦ].Ключ=_БумагаБлокаТМЦ.ТМЦ
			Left JOIN _СправочникБумагиБлока On _СправочникБумагиБлока.Ключ=_БумагаБлокаТМЦ.БумагаБлока
		Where БумагаБлока=@paper_bl
			  and Ролль=@is_roll
			  and _Ширина>=@xPaperBl
		      and _Длина>=@yPaperBl
		order By (ТМЦ._Ширина*ТМЦ._Длина) Asc

		Set @TMSPaper=ISNULL(@TMSPaper,0) 
	             	
     END -- if @is_roll = 0 begin
  
-- Выборка бумаги роля   
	If @is_roll=1
	Begin

		SELECT  Top 1  
				@TMSPaper=ТМЦ,
				@xPaperTMS=_Ширина  
		FROM [_БумагаБлокаТМЦ]
				Left JOIN [ТМЦ] With (NoLock)  On [ТМЦ].Ключ=_БумагаБлокаТМЦ.ТМЦ
				Left JOIN _СправочникБумагиБлока On _СправочникБумагиБлока.Ключ=_БумагаБлокаТМЦ.БумагаБлока
		Where БумагаБлока=@paper_bl
				and Ролль=@is_roll
				and _Ширина>=@dRoll
		order By ТМЦ._Ширина Asc

		Set @TMSPaper=ISNULL(@TMSPaper,0) 
	End -- if @is_roll = 1 begin    
     
    Select @NamePaper = ТМЦ.Название From ТМЦ Where ТМЦ.Ключ = @TMSPaper    

	return @NamePaper
End

----------------------------------------------------------------------------------------

ALTER function [dbo].[_IE_FindPaper_name_bl_key]
(
 @_name_bl_key INT				    ----- Ключ таблицы _name_bl
 )

RETURNS nvarchar(50)

as 
BEGIN

	Declare @i_Size INT				    ----- Ключ таблицы _СправочникРазмеровБлоков 
	Declare @paper_bl INT               ----- Ключ таблицы _СправочникБумагиБлока
	Declare @NamePaper nvarchar(50)
			     

    SELECT @i_Size =_СправочникРазмеровБлоков.Ключ,
           @paper_bl =_СправочникБумагиБлока.Ключ  
    FROM _name_bl
		join  _СправочникРазмеровБлоков on _СправочникРазмеровБлоков.Ключ = _name_bl.РазмерБлока
		join  _СправочникБумагиБлока on _СправочникБумагиБлока.Ключ = _name_bl.ТипИзделия
	where _name_bl.ключ = @_name_bl_key
   
    Select @NamePaper = [dbo].[_IE_FindPaper] (@i_Size, @paper_bl) 

	return @NamePaper
End

------------------------------------------------------------------------------------------

