﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Distr].[TECH_TYPE_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Distr].[TECH_TYPE_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [Distr].[TECH_TYPE_INSERT]
	@TT_NAME	VARCHAR(50),
	@TT_SHORT	VARCHAR(50),
	@TT_REG		INT,
	@TT_COEF	DECIMAL(8, 4),
	@TT_DATE	SMALLDATETIME,
	@TT_ID		UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'TECH_TYPE', NULL, @OLD OUTPUT


	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	DECLARE @MASTERID UNIQUEIDENTIFIER

	INSERT INTO Distr.TechType(TTMS_ID)
	OUTPUT INSERTED.TTMS_ID INTO @TBL
	DEFAULT VALUES


	SELECT	@MASTERID = ID
	FROM	@TBL

	DELETE
	FROM	@TBL


	INSERT INTO
			Distr.TechTypeDetail(
				TT_NAME,
				TT_SHORT,
				TT_REG,
				TT_COEF,
				TT_DATE,
				TT_ID_MASTER
			)
	OUTPUT INSERTED.TT_ID INTO @TBL(ID)
	VALUES	(
				@TT_NAME,
				@TT_SHORT,
				@TT_REG,
				@TT_COEF,
				@TT_DATE,
				@MASTERID
			)

	SELECT	@TT_ID = ID
	FROM	@TBL

	EXEC Common.PROTOCOL_VALUE_GET 'TECH_TYPE', @MASTERID, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'TECH_TYPE', 'Новая запись', @MASTERID, @OLD, @NEW

END

GO
GRANT EXECUTE ON [Distr].[TECH_TYPE_INSERT] TO rl_tech_type_i;
GO
