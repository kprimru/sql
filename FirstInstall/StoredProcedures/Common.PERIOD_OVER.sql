USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[PERIOD_OVER]
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
		EXEC Common.PERIOD_OVER_ONE @ID, @DATE

		FETCH NEXT FROM LST INTO @ID
	END

	CLOSE LST
	DEALLOCATE LST
END

GO
GRANT EXECUTE ON [Common].[PERIOD_OVER] TO rl_period_d;
GO
