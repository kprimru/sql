USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[EIS@Create?Document]
    @Act_Id			Int,
	@File_Id        VarChar(100),
	@MainContent    VarChar(Max),
    @ApplyContent   VarChar(Max)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

	DECLARE
		@DocumentXml	Xml,
		@MainBase64     VarChar(Max),
        @ApplyBase64    VarChar(Max);

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

		SET @MainBase64 = (SELECT CAST('<?xml version="1.0" encoding="windows-1251" standalone="yes"?>' + Convert(VarChar(Max), @MainContent, 1) AS VarBinary(Max)) FOR XML PATH(''), BINARY BASE64);
        SET @ApplyBase64 = (SELECT CAST('<?xml version="1.0" encoding="windows-1251" standalone="yes"?>' + Convert(VarChar(Max), @ApplyContent, 1) AS VarBinary(Max)) FOR XML PATH(''), BINARY BASE64);

        SET @DocumentXml =
        (
            SELECT
                [ИдТрПакет]     = Cast(NewId() AS VarChar(100)),
                [ИдФайл]        = 'ON_NSCHFDOPPR_' + F.[EIS_CODE] + '_' + O.[EIS_CODE] + '_' + Convert(VarChar(20), GetDate(), 112) + '_' + @File_Id,
                [ВерсФорм]      = '1.01',
                [ТипПрилож]     = 'УПДПрод',
                [ИдОтпр]        = O.[EIS_CODE],
                [ИдПол]         = F.[EIS_CODE],
                [ДатаВрФормир]  = GetDate(),
                (
                    SELECT
                        [Контент] = @MainBase64
                    FOR XML PATH('Документ'), TYPE
                ),
                (
                    SELECT
                        [Контент] = @ApplyBase64
                    FOR XML PATH('Прилож'), TYPE
                )
            FROM dbo.ActTable AS A
            INNER JOIN dbo.OrganizationTable AS O ON A.ACT_ID_ORG = O.ORG_ID
            INNER JOIN dbo.ClientFinancing AS F ON F.ID_CLIENT = IsNull(ACT_ID_PAYER, ACT_ID_CLIENT)
            WHERE ACT_ID = @Act_Id
            FOR XML RAW('ФайлПакет'), TYPE
        );

		SELECT [Data] = Cast(@DocumentXml AS VarChar(Max));

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[EIS@Create?Document] TO rl_act_p;
GO
