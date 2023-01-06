USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[EIS@Create?Apply]
    @Act_Id			Int,
	@File_Id        VarChar(100),
	@IdentGUId      VarChar(100),
	@StageGuid		VarChar(100)	= NULL,
	@ProductGuid	VarChar(100)	= NULL,
	@Grouping		Bit				= 1,
	@Detail			Bit				= 0,
	@Data			Xml				= NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        SELECT @Data = A.[Data]
		FROM [dbo].[EIS@Create?Apply(Internal)]
		(
			    @Act_Id,
				@File_Id,
				@IdentGUId,
				@StageGuid,
				@ProductGuid,
				@Grouping,
				@Detail
		) AS A

		SELECT [Data] = Cast(@Data AS VarChar(Max));

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[EIS@Create?Apply] TO rl_act_p;
GO
