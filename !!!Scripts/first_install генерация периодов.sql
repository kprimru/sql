DECLARE
	@CurMonth	TinyInt,
	@CurName	VarChar(50),
	@Today		SmallDateTime,
	@Year		Int,
	@CurDate	SmallDateTime,
	@Name		VarChar(256),
	@Start		SmallDateTime,
	@Finish		SmallDateTime;

DECLARE @Monthes Table
(
	Number	TinyInt,
	Name	VarChar(50),
	Primary Key Clustered (Number)
);

INSERT INTO @Monthes VALUES (1, '������');
INSERT INTO @Monthes VALUES (2, '�������');
INSERT INTO @Monthes VALUES (3, '����');
INSERT INTO @Monthes VALUES (4, '������');
INSERT INTO @Monthes VALUES (5, '���');
INSERT INTO @Monthes VALUES (6, '����');
INSERT INTO @Monthes VALUES (7, '����');
INSERT INTO @Monthes VALUES (8, '������');
INSERT INTO @Monthes VALUES (9, '��������');
INSERT INTO @Monthes VALUES (10, '�������');
INSERT INTO @Monthes VALUES (11, '������');
INSERT INTO @Monthes VALUES (12, '�������');

SET @Today = Common.DateOf(GetDate())

/*
��� ��� ��������� �� ����� ��� ��������� �������
*/	
SET @Year = 2020;

	
BEGIN TRY
	BEGIN TRAN;
	
	SET @CurDate = Convert(SmallDateTime, Cast(@Year AS VarCHar(20)) + '0101', 112);
	
	
	SET @CurMonth = 0;
	
	WHILE (1 = 1) BEGIN
		SELECT TOP (1)
			@CurMonth	= Number,
			@CurName	= Name
		FROM @Monthes
		WHERE Number > @CurMonth
		ORDER BY
			Number;
			
		IF @@RowCount < 1
			BREAK;
			
		SELECT
			@Name = @CurName + ' ' + Cast(@Year AS VarChar(20)),
			@Start = DateAdd(Month, @CurMonth - 1, @CurDate),
			@Finish = DateAdd(Day, -1, DateAdd(Month, @CurMonth, @CurDate));
		
		IF NOT EXISTS(SELECT * FROM [Common].[PeriodDetail] WHERE PR_REF = 1 AND PR_NAME = @Name)
			EXEC Common.PERIOD_INSERT
				@PR_NAME		= @Name,
				@PR_BEGIN_DATE	= @Start,
				@PR_END_DATE	= @Finish,
				@PR_DATE		= @Today;
	END;
	
	SELECT
		@Name = 'I ��������� ' + Cast(@Year AS VarChar(20)),
		@Start = DateAdd(Month, 0, @CurDate),
		@Finish = DateAdd(Day, -1, DateAdd(Month, 6, @CurDate));
	
	IF NOT EXISTS(SELECT * FROM [Common].[HalfDetail] WHERE HLF_REF = 1 AND HLF_NAME = @Name)
			EXEC Common.HALF_INSERT
				@HLF_NAME		= @Name,
				@HLF_BEGIN_DATE	= @Start,
				@HLF_END_DATE	= @Finish,
				@HLF_DATE		= @Today;
	
	SELECT
		@Name = 'II ��������� ' + Cast(@Year AS VarChar(20)),
		@Start = DateAdd(Month, 6, @CurDate),
		@Finish = DateAdd(Day, -1, DateAdd(Month, 12, @CurDate));
	
	IF NOT EXISTS(SELECT * FROM [Common].[HalfDetail] WHERE HLF_REF = 1 AND HLF_NAME = @Name)
			EXEC Common.HALF_INSERT
				@HLF_NAME		= @Name,
				@HLF_BEGIN_DATE	= @Start,
				@HLF_END_DATE	= @Finish,
				@HLF_DATE		= @Today;
	
	COMMIT TRAN;
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
END CATCH