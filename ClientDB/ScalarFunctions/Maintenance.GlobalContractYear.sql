﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[GlobalContractYear]', 'FN') IS NULL EXEC('CREATE FUNCTION [Maintenance].[GlobalContractYear] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [Maintenance].[GlobalContractYear]
()
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @RES UNIQUEIDENTIFIER

	DECLARE @TMP VARCHAR(500)

	SELECT @TMP = GS_VALUE
	FROM Maintenance.GlobalSettings
	WHERE GS_NAME = 'CONTRACT_YEAR'

	SET @RES = Cast(@TMP AS UniqueIdentifier)

	RETURN @RES
END
GO
