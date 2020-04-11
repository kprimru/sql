USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ONLINE_SERVICE_DISTR_SET]
	@Host_Id	SmallInt,
	@Distr		Int,
	@Comp		TinyInt,
	@Hotline	Bit,
	@Expert		Bit
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@HotlineIsActive	Bit,
		@ExpertIsActive		Bit;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF EXISTS
			(
				SELECT TOP (1) *
				FROM dbo.HotlineDistr
				WHERE	ID_HOST = @Host_Id
					AND DISTR = @Distr
					AND COMP = @Comp
					AND STATUS = 1
			)
			SET @HotlineIsActive = 1
		ELSE
			SET @HotlineIsActive = 0;
			
		IF EXISTS
			(
				SELECT TOP (1) *
				FROM dbo.ExpDistr
				WHERE	ID_HOST = @Host_Id
					AND DISTR = @Distr
					AND COMP = @Comp
					AND STATUS = 1
			)
			SET @ExpertIsActive = 1
		ELSE
			SET @ExpertIsActive = 0;

		IF @HotlineIsActive = 0 AND @Hotline = 1
			INSERT INTO dbo.HotlineDistr(ID_HOST, DISTR, COMP)
			VALUES(@Host_Id, @Distr, @Comp);
		ELSE IF @HotlineIsActive = 1 AND @Hotline = 0
			UPDATE dbo.HotlineDistr
			SET STATUS = 2,
				UNSET_DATE = GETDATE(),
				UNSET_USER = ORIGINAL_LOGIN()
			WHERE	ID_HOST = @Host_Id
				AND DISTR = @Distr
				AND COMP = @Comp
				AND STATUS = 1;
				
		IF @ExpertIsActive = 0 AND @Expert = 1
			INSERT INTO dbo.ExpDistr(ID_HOST, DISTR, COMP)
			VALUES(@Host_Id, @Distr, @Comp)
		ELSE IF @ExpertIsActive = 1 AND @Expert = 0
			UPDATE dbo.ExpDistr
			SET STATUS = 2,
				UNSET_DATE = GETDATE(),
				UNSET_USER = ORIGINAL_LOGIN()
			WHERE	ID_HOST = @Host_Id
				AND DISTR = @Distr
				AND COMP = @Comp
				AND STATUS = 1
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
