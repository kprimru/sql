﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Personal].[DEPARTMENT_OVER_ONE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Personal].[DEPARTMENT_OVER_ONE]  AS SELECT 1')
GO
ALTER PROCEDURE [Personal].[DEPARTMENT_OVER_ONE]
	@IDLIST	UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME,
	@RC		INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @MASTERID UNIQUEIDENTIFIER

	SELECT @MASTERID = DP_ID_MASTER
	FROM Personal.DepartmentDetail
	WHERE DP_ID = @IDLIST

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'DEPARTMENT', @MASTERID, @OLD OUTPUT

	UPDATE	Personal.DepartmentDetail
	SET		DP_END	=	@DATE,
			DP_REF	=	3
	WHERE	DP_ID	=	@IDLIST

	EXEC Common.PROTOCOL_VALUE_GET 'DEPARTMENT', NULL, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'DEPARTMENT', 'Удаление', @MASTERID, @OLD, @NEW

END

GO
