﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Clients].[VENDOR_OVER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Clients].[VENDOR_OVER]  AS SELECT 1')
GO
ALTER PROCEDURE [Clients].[VENDOR_OVER]
	@IDLIST	VARCHAR(MAX),
	@DATE	SMALLDATETIME,
	@RC		INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @ID	UNIQUEIDENTIFIER

	DECLARE LST CURSOR LOCAL FOR
		SELECT	ID
		FROM	Common.TableFromList(@IDLIST, ',')

	OPEN LST

	FETCH NEXT FROM LST INTO @ID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC Clients.VENDOR_OVER_ONE @ID, @DATE

		FETCH NEXT FROM LST INTO @ID
	END

	CLOSE LST
	DEALLOCATE LST
END

GO
GRANT EXECUTE ON [Clients].[VENDOR_OVER] TO rl_vendor_d;
GO
