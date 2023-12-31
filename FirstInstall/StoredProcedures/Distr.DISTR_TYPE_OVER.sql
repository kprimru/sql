USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[DISTR_TYPE_OVER]
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
		EXEC Distr.DISTR_TYPE_OVER_ONE @ID, @DATE

		FETCH NEXT FROM LST INTO @ID
	END

	CLOSE LST
	DEALLOCATE LST
END

GO
GRANT EXECUTE ON [Distr].[DISTR_TYPE_OVER] TO rl_distr_type_d;
GO
