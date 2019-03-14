USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Personal].[PERSONAL_TYPE_INSERT]
	@PT_NAME	VARCHAR(50),
	@PT_ALIAS	VARCHAR(50),
	@PT_DATE	SMALLDATETIME,
	@PT_ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL_TYPE', NULL, @OLD OUTPUT

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)	

	DECLARE @MASTERID UNIQUEIDENTIFIER
	
	INSERT INTO Personal.PersonalType(PTMS_ID) 
	OUTPUT INSERTED.PTMS_ID INTO @TBL 
	DEFAULT VALUES

	
	SELECT	@MASTERID = ID 
	FROM	@TBL

	DELETE 
	FROM	@TBL	


	INSERT INTO 
			Personal.PersonalTypeDetail(
				PT_NAME,
				PT_ALIAS,
				PT_DATE,
				PT_ID_MASTER
			)
	OUTPUT INSERTED.PT_ID INTO @TBL(ID)
	VALUES	(
				@PT_NAME,
				@PT_ALIAS,
				@PT_DATE,
				@MASTERID
			)
	
	SELECT	@PT_ID = ID
	FROM	@TBL

	EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL_TYPE', @MASTERID, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'PERSONAL_TYPE', '����� ������', @MASTERID, @OLD, @NEW
END

