USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[DISTR_SUBHOST_PROCESS]
	@ID		NVARCHAR(MAX),
	@SH		UNIQUEIDENTIFIER,
	@COM	NVARCHAR(150)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Distr.DistrIncome
	SET ID_SUBHOST = @SH,
		COMMENT = @COM,
		PROCESS_DATE = CASE WHEN @SH IS NULL THEN NULL ELSE GETDATE() END
	WHERE ID IN
		(
			SELECT ID
			FROM Common.TableFromList(@ID, ',')
		)
END
GRANT EXECUTE ON [Distr].[DISTR_SUBHOST_PROCESS] TO rl_distr_income_w;
GO