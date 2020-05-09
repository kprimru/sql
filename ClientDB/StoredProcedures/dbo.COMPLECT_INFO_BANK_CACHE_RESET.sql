USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[COMPLECT_INFO_BANK_CACHE_RESET]
	@Complect	VarChar(100)	= NULL,
	@Client_Id	Int				= NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF @Complect IS NOT NULL
			DELETE FROM dbo.ComplectInfoBankCache WHERE Complect = @Complect;
		ELSE IF @Client_Id IS NOT NULL
		BEGIN
			DECLARE
				@RowIndex		SmallInt,
				@CurComplect	VarChar(100);

			DECLARE
				@Complects Table
				(
					RowIndex	SmallInt		NOT NULL	Identity(1,1),
					Complect	VarChar(100)	NOT NULL,
					Primary Key Clustered(RowIndex)
				);

			INSERT INTO @Complects
			SELECT DISTINCT R.Complect
			FROM Reg.RegNodeSearchView		R WITH(NOEXPAND)
			INNER JOIN dbo.ClientDistrView	D WITH(NOEXPAND) ON R.DistrNumber	= D.DISTR
															AND R.CompNumber	= D.COMP
															AND R.HostId		= D.HostId
			WHERE	D.ID_CLIENT = @Client_Id
				AND R.DS_REG = 0
				AND D.DS_REG = 0
				AND R.Complect IS NOT NULL;

			SET @RowIndex = 0;

			WHILE (1 = 1) BEGIN
				SELECT TOP (1)
					@RowIndex = RowIndex,
					@CurComplect = Complect
				FROM @Complects
				WHERE RowIndex > @RowIndex
				ORDER BY RowIndex;

				IF @@RowCount < 1
					BREAK;

				EXEC [dbo].[COMPLECT_INFO_BANK_CACHE_RESET]
					@Complect = @CurComplect;
			END;

			RETURN;
		END
		ELSE
			TRUNCATE TABLE dbo.ComplectInfoBankCache;


		INSERT INTO dbo.ComplectInfoBankCache(Complect, InfoBankID, InfoBankName)
		SELECT DISTINCT rns.Complect, cgl.InfoBankID, cgl.InfoBankName
		FROM
		(
			SELECT DISTINCT rns.Complect
			FROM Reg.RegNodeSearchView rns WITH(NOEXPAND)
			WHERE	DS_REG = 0
				AND SubhostName NOT IN ('Ó1', 'Í1', 'Ì', 'Ë1')
				AND (rns.Complect = @Complect OR @Complect IS NULL)
		) rns
		CROSS APPLY dbo.ComplectGetBanks(rns.Complect, NULL) cgl
		--/*
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Reg.RegNodeSearchView rns2 WITH(NOEXPAND)
				WHERE	rns2.Complect = rns.Complect
					AND SubhostName IN ('Ó1', 'Í1', 'Ì', 'Ë1')
					AND DS_REG = 0
			)
		--*/

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
