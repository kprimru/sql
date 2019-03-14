USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Distr].[SYSTEM_INSERT]	
	@SYS_NAME		VARCHAR(50),
	@SYS_SHORT		VARCHAR(50),	
	@SYS_DATE		SMALLDATETIME,
	@SYS_REG		VARCHAR(50),
	@SYS_ORDER		INT,
	@SYS_ID			UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'SYSTEM', NULL, @OLD OUTPUT

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)	

	DECLARE @MASTERID UNIQUEIDENTIFIER
	
	INSERT INTO Distr.Systems(SYSMS_ID)		
	OUTPUT INSERTED.SYSMS_ID INTO @TBL 
	DEFAULT VALUES

	
	SELECT	@MASTERID = ID 
	FROM	@TBL

	DELETE 
	FROM	@TBL	


	INSERT INTO 
			Distr.SystemDetail(
				SYS_NAME,
				SYS_SHORT,
				SYS_DATE,
				SYS_ID_MASTER,
				SYS_ORDER,
				SYS_REG
			)
	OUTPUT INSERTED.SYS_ID INTO @TBL(ID)
	VALUES	(
				@SYS_NAME,
				@SYS_SHORT,			
				@SYS_DATE,
				@MASTERID,
				@SYS_ORDER,
				@SYS_REG
			)
	
	SELECT	@SYS_ID = ID
	FROM	@TBL

	EXEC Common.PROTOCOL_VALUE_GET 'SYSTEM', @MASTERID, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'SYSTEM', '����� ������', @MASTERID, @OLD, @NEW

	--EXEC [Distr].[SYSTEM_WEIGHT]
END

