USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[EIS@Create]
    @Act_Id			Int,
	@MainContent    Xml,
    @ApplyContent   Xml,
	@Document		Xml,
	@File_Id        VarChar(100)
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

        SET @File_Id    = Cast(NewId() AS VarChar(100));

        SELECT
            [Folder]        = Replace(Replace(Replace(RTrim(Ltrim(C.CL_PSEDO)), '\', ''), ':', ''), '/', ''),
            [FileName]      = IsNull(Replace(Replace(Replace(F.[FileName], '\', ''), ':', ''), '/', ''), Cast(NewId() AS VarChar(50))), -- ToDo костыль
            [Data]          = F.[Data]
        FROM dbo.ActTable           AS A
        INNER JOIN dbo.ClientTable  AS C ON A.ACT_ID_CLIENT = C.CL_ID
        CROSS APPLY
        (
            SELECT
                [FileName]  = 'УПД_' + Replace(C.CL_PSEDO, ' ', '_') + '_' + Convert(VarChar(50), ACT_DATE, 112) + '_' + @File_Id + '.xml',
                [Data]      = Cast(@Document AS VarChar(Max))
            ---
            UNION ALL
            ---
            SELECT
                [FileName]  = @MainContent.value('(/Файл/@ИдФайл)[1]', 'VarChar(256)') + '.xml',
                [Data]      = Cast(@MainContent AS VarChar(Max))
            ---
            UNION ALL
            ---
            SELECT
                [FileName]  = @ApplyContent.value('(/ФайлУПДПрод/@ИдПрилож)[1]', 'VarChar(256)') + '.xml',
                [Data]      = Cast(@ApplyContent AS VarChar(Max))
        )AS F
        WHERE A.ACT_ID = @Act_Id;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[EIS@Create] TO rl_act_p;
GO
