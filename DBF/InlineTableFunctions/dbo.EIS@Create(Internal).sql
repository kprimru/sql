USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EIS@Create(Internal)]', 'IF') IS NULL EXEC('CREATE FUNCTION [dbo].[EIS@Create(Internal)] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [dbo].[EIS@Create(Internal)]
(
	@Act_Id			Int,
	@Invoice_Id		Int,
	@MainContent    Xml,
    @ApplyContent   Xml,
	@Document		Xml,
	@File_Id        VarChar(100),
	@SubFolder		VarChar(100) = NULL
)
RETURNS TABLE
AS
RETURN
(

    SELECT
        [Folder]        = Replace(Replace(Replace(RTrim(Ltrim(C.CL_PSEDO)), '\', ''), ':', ''), '/', '') + IsNull('\' + @SubFolder, ''),
        [FileName]      = IsNull(Replace(Replace(Replace(F.[FileName], '\', ''), ':', ''), '/', ''), Cast((SELECT [NewId] FROM [dbo].[NewIdView]) AS VarChar(100))), -- ToDo костыль
        [Data]          = F.[Data]
    FROM
	(
		SELECT ACT_ID_CLIENT, ACT_DATE
		FROM dbo.ActTable           AS A
		WHERE A.ACT_ID = @Act_Id

		UNION ALL

		SELECT INS_ID_CLIENT, INS_DATE
		FROM dbo.InvoiceSaleTable
		WHERE INS_ID = @Invoice_Id
	) AS A
    INNER JOIN dbo.ClientTable  AS C ON A.ACT_ID_CLIENT = C.CL_ID
    CROSS APPLY
    (
        SELECT
            [FileName]  = 'УПД_' + Replace(C.CL_PSEDO, ' ', '_') + '_' + Convert(VarChar(50), ACT_DATE, 112) + '_' + Cast((SELECT [NewId] FROM [dbo].[NewIdView]) AS VarChar(100)) + '.xml',
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
)GO
