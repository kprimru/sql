USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Book].[BOOK_BONUS_INSERT]
	@PT_ID		UNIQUEIDENTIFIER,
	@BB_PERCENT	DECIMAL(8, 4),
	@BB_DATE	SMALLDATETIME,
	@BB_ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'BOOK_BONUS', NULL, @OLD OUTPUT


	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)	

	DECLARE @MASTERID UNIQUEIDENTIFIER
	
	INSERT INTO Book.BookBonus(BBMS_ID) 
	OUTPUT INSERTED.BBMS_ID INTO @TBL 
	DEFAULT VALUES

	
	SELECT @MASTERID = ID 
	FROM @TBL

	DELETE 
	FROM @TBL	


	INSERT INTO 
			Book.BookBonusDetail(
				BB_ID_PT,
				BB_PERCENT,
				BB_DATE,
				BB_ID_MASTER
			)
	OUTPUT INSERTED.BB_ID INTO @TBL(ID)
	VALUES	(
				@PT_ID,
				@BB_PERCENT,
				@BB_DATE,
				@MASTERID
			)
	
	SELECT	@BB_ID = ID
	FROM	@TBL

	EXEC Common.PROTOCOL_VALUE_GET 'BOOK_BONUS', @MASTERID, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'BOOK_BONUS', '����� ������', @MASTERID, @OLD, @NEW
END

