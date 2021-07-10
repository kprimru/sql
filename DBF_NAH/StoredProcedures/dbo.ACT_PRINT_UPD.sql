USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_PRINT?UPD]
    @Act_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @Data           Xml,
        @MainContent    Xml,
        @ApplyContent   Xml,
        @File_Id        VarChar(100),
        @MainBase64     VarChar(Max),
        @ApplyBase64    VarChar(Max);

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        SET @File_Id = Cast(NewId() AS VarChar(100));

        SET @MainContent =
        (
            SELECT
                [������]    = 'ON_NSCHFDOPPR_' + F.[EIS_CODE] + '_' + O.[EIS_CODE] + '_' + Convert(VarChar(20), GetDate(), 112) + '_' + @File_Id,
                [��������]  = '5.01',
                [��������]  = '11.0',
                (
                    SELECT
                        [������]    = O.[EIS_CODE],
                        [�����]     = F.[EIS_CODE],
                        (
                            SELECT
                                [�����]     = '7710568760',
                                [�������]   = '����������� ������������',
                                [�����]     = '2ZK'
                            FOR XML RAW ('���������'), TYPE
                        )
                    FOR XML RAW('�����������'), TYPE
                ),
                (
                    SELECT
                        [���]               = '1115131',
                        [�������]           = '������',
                        [���������]         = Convert(VarChar(20), GetDate(), 104),
                        [���������]         = Replace(Convert(VarChar(20), GetDate(), 108), ':', '.'),
                        [��������]          = '�������� �� �������� ������� (���������� �����), �������� ������������� ���� (�������� �� �������� �����)',
                        [����������]        = '�������� �� �������� ������� (���������� �����), �������� ������������� ���� (�������� �� �������� �����)',
                        [���������������]   = O.ORG_FULL_NAME,
                        [�������������]     = '0000.0000.0000',
                        (
                            SELECT
                                [��������]  = I.INS_NUM,
                                --[�������]   = Convert(VarChar(20), I.INS_DATE, 104),
                                [�������]   = Convert(VarChar(20), GetDate(), 104),
                                [������]    = 643,
                                (
                                    SELECT
                                        [���������] = O.ORG_SHORT_NAME,
                                        (
                                            SELECT
                                                [�������]   = O.ORG_FULL_NAME,
                                                [�����]     = O.ORG_INN,
                                                [���]       = O.ORG_KPP
                                            FOR XML RAW('������'), TYPE, ROOT('����')
                                        ),
                                        (
                                            SELECT
                                                [������]    = O.ORG_INDEX,
                                                [���������] = C.CT_REGION,
                                                [�����]     = C.CT_NAME,
                                                [�����]     = S.ST_NAME,
                                                [���]       = ORG_HOME
                                            FROM dbo.StreetTable AS S
                                            INNER JOIN dbo.CityTable AS C ON S.ST_ID_CITY = C.CT_ID
                                            WHERE S.ST_ID = O.ORG_ID_STREET
                                            FOR XML RAW('�����'), TYPE, ROOT('�����')
                                        ),
                                        (
                                            SELECT
                                                [���]       = O.ORG_PHONE,
                                                [�������]   = O.ORG_EMAIL
                                            FOR XML RAW('�������'), TYPE
                                        ),
                                        (
                                            SELECT
                                                [Id] = NULL
                                            FOR XML RAW('������'), TYPE, ROOT('��������')
                                        )
                                    FOR XML RAW ('������'), TYPE
                                ),
                                (
                                    SELECT
                                        [����]      = CL.CL_OKPO,
                                        [���������] = F.EIS_DATA.value('(/export/contract/customer/shortName)[1]', 'VarChar(512)'),
                                        (
                                            SELECT
                                                [�������]   = F.EIS_DATA.value('(/export/contract/customer/fullName)[1]', 'VarChar(512)'),--CL.CL_FULL_NAME,
                                                [�����]     = CL.CL_INN,
                                                [���]       = CL.CL_KPP
                                            FOR XML RAW('������'), TYPE, ROOT('����')
                                        ),
                                        (
                                            SELECT
                                                [������]    = CA.CA_INDEX,
                                                [���������] = CA.CT_REGION,
                                                [�����]     = CA.AR_NAME,
                                                [�����]     = CA.CT_NAME,
                                                [�����]     = CA.ST_NAME,
                                                [���]       = CA_HOME
                                            FROM dbo.ClientAddressView AS CA
                                            WHERE CA.CA_ID_CLIENT = CL.CL_ID
                                                AND CA.CA_ID_TYPE = 1
                                            FOR XML RAW('�����'), TYPE, ROOT('�����')
                                        ),
                                        (
                                            SELECT
                                                [���]       = NullIf(CL.CL_PHONE, ''),
                                                [�������]   = NullIf(CL.CL_EMAIL, '')
                                            FOR XML RAW('�������'), TYPE
                                        ),
                                        (
                                            SELECT
                                                [Id] = NULL
                                            FOR XML RAW('������'), TYPE, ROOT('��������')
                                        )
                                    FROM dbo.ClientTable AS CL
                                    WHERE CL.CL_ID = I.INS_ID_CLIENT
                                    FOR XML RAW ('�������'), TYPE
                                ),
                                (
                                    SELECT
                                        [�������] = '���������� �����',
                                        (
                                            SELECT TOP (1)
                                                [�����������]   = Convert(VarChar(20), CO_DATE, 104),
                                                [������������]  = CO_NUM
                                            FROM dbo.ContractTable AS CO
                                            INNER JOIN dbo.ContractDistrTable AS CD ON CD.COD_ID_CONTRACT = CO_ID
                                            INNER JOIN dbo.ActDistrTable AS AD ON AD.AD_ID_ACT = A.ACT_ID AND AD.AD_ID_DISTR = CD.COD_ID_DISTR
                                            WHERE CO_ID_CLIENT = A.ACT_ID_CLIENT
                                                AND CO_ACTIVE = 1
                                            FOR XML RAW('�����������������'), TYPE
                                        )
                                    FOR XML RAW('��������1'), TYPE
                                )
                            FOR XML RAW('��������'), TYPE
                        ),
                        (
                            SELECT
                                (
                                    SELECT
                                        [������]        = 1,
                                        [�������]       = F.EIS_DATA.value('(/export/contract/products/product/name)[1]', 'VarChar(Max)'),
                                        --[�������]       = Max(INR_GOOD),
                                        [����_���]      = F.EIS_DATA.value('(/export/contract/products/product/OKEI/code)[1]', 'VarChar(100)'),
                                        [������]        = 1,
                                        [�������]       = CASE WHEN ACT_ID_CLIENT = 4707 THEN '27217.66666666667' ELSE dbo.MoneyFormatCustom(Sum(R.INR_SUM * IsNull(R.INR_COUNT, 1)), '.') END,
                                        --Replace(Cast(Round(Cast(Sum(R.INR_SALL)AS Decimal(20,12))/1.2, 11) As VarChar(50)), ',', '.'),
                                        --
                                        [�����������]   = dbo.MoneyFormatCustom(Sum(R.INR_SUM * IsNull(R.INR_COUNT, 1)), '.'),
                                        [�����]         = '20%',
                                        [����������]    = dbo.MoneyFormatCustom(Sum(R.INR_SALL), '.'),
                                        (
                                            SELECT
                                                [��������] = '��� ������'
                                            FOR XML PATH('�����'), TYPE
                                        ),
                                        (
                                            SELECT
                                                [������] = dbo.MoneyFormatCustom(Sum(R.INR_SNDS), '.')
                                            FOR XML PATH('������'), TYPE
                                        ),
                                        (
                                            SELECT
                                                [��������]      = 2,
                                                [���������]     = F.EIS_DATA.value('(/export/contract/products/product/OKEI/fullName)[1]', 'VarChar(100)'),
                                                [�����������]   = '���������� ���������',
                                                [������]        = F.EIS_DATA.value('(/export/contract/products/product/OKPD2/code)[1]', 'VarChar(100)')
                                            FOR XML RAW('����������'), TYPE
                                        )
                                    FROM dbo.InvoiceRowTable AS R
                                    INNER JOIN dbo.DistrView AS D WITH(NOEXPAND) ON R.INR_ID_DISTR = D.DIS_ID
                                    INNER JOIN dbo.SaleObjectTable AS S ON S.SO_ID = D.SYS_ID_SO
                                    INNER JOIN dbo.TaxTable AS T ON T.TX_ID = R.INR_ID_TAX
                                    WHERE R.INR_ID_INVOICE = I.INS_ID
                                    FOR XML RAW('�������'), TYPE
                                ),
                                (
                                    SELECT
                                        [����������������]  = dbo.MoneyFormatCustom(Sum(R.INR_SUM * IsNull(R.INR_COUNT, 1)), '.'),
                                        [���������������]   = dbo.MoneyFormatCustom(Sum(R.INR_SALL), '.'),
                                        (
                                            SELECT
                                                [������] = dbo.MoneyFormatCustom(Sum(R.INR_SNDS), '.')
                                            FOR XML PATH('�����������'), TYPE
                                        )
                                    FROM dbo.InvoiceRowTable AS R
                                    WHERE R.INR_ID_INVOICE = I.INS_ID
                                    FOR XML RAW('��������'), TYPE
                                )
                            FOR XML RAW('����������'), TYPE
                        ),
                        (
                            SELECT
                                (
                                    SELECT
                                        [�������]   = '������ ������� � ������ ������',
                                        --ToDo �������� �������������� �����?
                                        [�������]   = '�������� �������������� ����� �� ' + DateName(MONTH, ACT_DATE) + ' ' + Cast(DatePart(Year, ACT_DATE) AS VarChar(100)) + ' �.',
                                        [�������]   = Convert(VarChar(20), ACT_DATE, 104),
                                        --[�������]   = Convert(VarChar(20), GetDate(), 104),
                                        [�������]   = Convert(VarChar(20), PR_DATE, 104),
                                        [��������]  = Convert(VarChar(20), PR_END_DATE, 104),
                                        (
                                            SELECT
                                                [�������]   = '��� ���������-���������'
                                            FOR XML RAW('������'), TYPE
                                        ),
                                        (
                                            SELECT
                                                [NULL]      = NULL
                                            FOR XML RAW('��������'), TYPE
                                        )
                                    FOR XML RAW('�����'), TYPE
                                )
                            FOR XML RAW('���������'), TYPE
                        ),
                        (
                            SELECT
                                [�������]   = 5,
                                [������]    = 1,
                                [�������]   = '����������� �����������',
                                (
                                    SELECT
                                        [�����]     = O.ORG_INN,
                                        [�������]   = O.ORG_FULL_NAME,
                                        [�����]     = O.ORG_DIR_POS,
                                        [��������]  = 1,
                                        (
                                            SELECT
                                                [�������] = ORG_DIR_FAM,
                                                [���] = ORG_DIR_NAME,
                                                [��������] = ORG_DIR_OTCH
                                            FOR XML RAW('���'), TYPE
                                        )
                                    FOR XML RAW('��'), TYPE
                                )
                            FOR XML RAW('���������'), TYPE
                        )
                    FOR XML RAW('��������'), TYPE
                )
            FROM dbo.ActTable AS A
            INNER JOIN dbo.OrganizationTable AS O ON A.ACT_ID_ORG = O.ORG_ID
            INNER JOIN dbo.InvoiceSaleTable AS I ON A.ACT_ID_INVOICE = I.INS_ID
            INNER JOIN dbo.PeriodTable AS P ON ACT_DATE BETWEEN PR_DATE AND PR_END_DATE
            INNER JOIN dbo.ClientFinancing AS F ON F.ID_CLIENT = A.ACT_ID_CLIENT
            WHERE ACT_ID = @Act_Id
            FOR XML RAW('����'), TYPE
        );

        SET @ApplyContent =
        (
            SELECT
                [��������]  = 'PRIL_ON_NSCHFDOPPR_' + F.[EIS_CODE] + '_' + O.[EIS_CODE] + '_' + Convert(VarChar(20), GetDate(), 112) + '_' + @File_Id,
                [������]    = 'ON_NSCHFDOPPR_' + F.[EIS_CODE] + '_' + O.[EIS_CODE] + '_' + Convert(VarChar(20), GetDate(), 112) + '_' + @File_Id,
                [��������]  = '1.00',
                [������]    = '1',
                (
                    SELECT
                        [�������������] = F.EIS_REG_NUM,
                        [����������]    = F.EIS_CONTRACT,
                        [����������]    = F.EIS_DATA.value('(/export/contract/finances/budgetFunds/stages/guid)[1]', 'VarChar(100)')
                    FOR XML RAW('��������'), TYPE
                ),
                (
                    SELECT
                        (
                            SELECT
                                [�����������] = O.[ORG_SHORT_NAME]
                            FOR XML RAW('��'), TYPE
                        )
                    FOR XML RAW('�������������'), TYPE
                ),
                (
                    SELECT
                        (
                            SELECT
                                (
                                    SELECT
                                        (
                                            SELECT
                                                [�����]         = F.EIS_DATA.value('(/export/contract/products/product/guid)[1]', 'VarChar(100)'),
                                                [������]        = F.EIS_DATA.value('(/export/contract/products/product/OKPD2/code)[1]', 'VarChar(100)'),
                                                [�������]       = F.EIS_DATA.value('(/export/contract/products/product/name)[1]', 'VarChar(Max)'),
                                                --[�������]       = Max(INR_GOOD),
                                                [��������]      = F.EIS_DATA.value('(/export/contract/products/product/OKEI/code)[1]', 'VarChar(100)'),
                                                [���������]     = F.EIS_DATA.value('(/export/contract/products/product/OKEI/fullName)[1]', 'VarChar(100)'),
                                                [���������]     = dbo.MoneyFormatCustom(Sum(R.INR_SUM * IsNull(R.INR_COUNT, 1)), '.'),
                                                [������]        = 1,
                                                [��������]      = 2,
                                                [�����������]   = dbo.MoneyFormatCustom(Sum(R.INR_SUM * IsNull(R.INR_COUNT, 1)), '.'),
                                                [�����]         = '20%',
                                                [����������]    = dbo.MoneyFormatCustom(Sum(R.INR_SALL), '.'),
                                                (
                                                    SELECT
                                                        (
                                                            SELECT
                                                                [������] = dbo.MoneyFormatCustom(Sum(R.INR_SNDS), '.')
                                                            FOR XML PATH(''), TYPE
                                                        )
                                                    FOR XML RAW('������'), TYPE
                                                ),
                                                (
                                                    SELECT
                                                        (
                                                            SELECT
                                                                [��������] = '��� ������'
                                                            FOR XML PATH(''), TYPE
                                                        )
                                                    FOR XML RAW('�����'), TYPE
                                                )/*,
                                                (
                                                    SELECT
                                                        [���]   = '643',
                                                        [����]  = '���������� ���������'
                                                    FOR XML RAW('������������'), TYPE
                                                )*/
                                            FROM dbo.InvoiceRowTable AS R
                                            WHERE R.INR_ID_INVOICE = I.INS_ID
                                            FOR XML RAW('�������'), TYPE
                                        ),
                                        (
                                            SELECT
                                                [������]    = '1',
                                                --[�����]     = F.EIS_DATA.value('(/export/contract/products/product/guid)[1]', 'VarChar(100)'),
                                                [�����]     = Replace(Cast(NewId() AS VarChar(100)), '-', ''),
                                                [��������]  = dbo.MoneyFormatCustom(Sum(R.INR_SALL), '.')
                                                /*,
                                                (
                                                    SELECT
                                                        [���]   = '643',
                                                        [����]  = '���������� ���������'
                                                    FOR XML RAW('������������'), TYPE
                                                )
                                                */
                                            FROM dbo.InvoiceRowTable AS R
                                            WHERE R.INR_ID_INVOICE = I.INS_ID
                                            FOR XML RAW('���������'), TYPE
                                        )
                                    FOR XML RAW('��������'), TYPE
                                )
                            FOR XML RAW('�������'), TYPE
                        )
                    FOR XML RAW('�������'), TYPE
                ),
                (
                    SELECT
                        (
                            SELECT
                                [�����] = IsNull(ST_PREFIX + ' ' + ST_NAME + ', ' + CA_HOME, CA_FREE),
                                (
                                    SELECT
                                        (
                                            SELECT
                                                [���]   = '25000001000',
                                                [����]  = CT_NAME,
                                                [�����] = '���������� ���������, ' + RG_NAME + ', ' + CT_NAME + ' ' + CT_PREFIX
                                            FOR XML RAW('�����'), TYPE
                                        )
                                    FOR XML RAW('�������'), TYPE
                                )
                                /*
                                (
                                    SELECT
                                        [���]   = '05701000001',
                                        [����]  = '����������� �',
                                        [�����] = '690002, ���� ���������� 25, � �����������, ��-�� ���������, ��� 8'
                                    FOR XML RAW('�������'), TYPE
                                )
                                */
                            FROM dbo.ClientAddressView AS CA
                            WHERE CA.CA_ID_CLIENT = A.ACT_ID_CLIENT
                                AND CA.CA_ID_TYPE = 1
                            FOR XML RAW('�����������������'), TYPE

                        )
                    FOR XML RAW('�����������������'), TYPE
                )
            FROM dbo.ActTable AS A
            INNER JOIN dbo.OrganizationTable AS O ON A.ACT_ID_ORG = O.ORG_ID
            INNER JOIN dbo.InvoiceSaleTable AS I ON A.ACT_ID_INVOICE = I.INS_ID
            INNER JOIN dbo.PeriodTable AS P ON ACT_DATE BETWEEN PR_DATE AND PR_END_DATE
            INNER JOIN dbo.ClientFinancing AS F ON F.ID_CLIENT = A.ACT_ID_CLIENT
            WHERE ACT_ID = @Act_Id
            FOR XML RAW('�����������'), TYPE
        );

        /*
        SET @ApplyContent =
        (
            SELECT
                [��������]  = 'PRIL_ON_NSCHFDOPPR_' + F.[EIS_CODE] + '_' + O.[EIS_CODE] + '_' + Convert(VarChar(20), GetDate(), 112) + '_' + @File_Id,
                [������]    = 'ON_NSCHFDOPPR_' + F.[EIS_CODE] + '_' + O.[EIS_CODE] + '_' + Convert(VarChar(20), GetDate(), 112) + '_' + @File_Id,
                [��������]  = '1.00',
                [������]    = '1',
                (
                    SELECT
                        [�������������] = F.EIS_REG_NUM,
                        [����������]    = F.EIS_CONTRACT,
                        [����������]    = F.EIS_DATA.value('(/export/contract/finances/budgetFunds/stages/guid)[1]', 'VarChar(100)')
                    FOR XML RAW('��������'), TYPE
                ),
                (
                    SELECT
                        (
                            SELECT
                                (
                                    SELECT
                                        [�����]         = F.EIS_DATA.value('(/export/contract/products/product/guid)[1]', 'VarChar(100)'),
                                        [��������]      = F.EIS_DATA.value('(/export/contract/products/product/sid)[1]', 'VarChar(100)'),
                                        [����������]    = F.EIS_DATA.value('(/export/contract/products/product/name)[1]', 'VarChar(100)'),
                                        (
                                            SELECT
                                                [������]            = '1',
                                                [��������������]    = dbo.MoneyFormatCustom(Sum(R.[INR_SALL]), '.'),
                                                (
                                                    SELECT
                                                        [���]   = '643',
                                                        [����]  = '������'
                                                    FOR XML RAW('������������'), TYPE
                                                )
                                            FOR XML RAW('��������'), TYPE
                                        )
                                    FROM dbo.InvoiceRowTable      AS R
                                    WHERE I.INS_ID = INR_ID_INVOICE
                                    FOR XML RAW('����������'), TYPE
                                )
                            FOR XML RAW('�������'), TYPE
                        )
                    FOR XML RAW('�������'), TYPE
                )
            FROM dbo.ActTable AS A
            INNER JOIN dbo.OrganizationTable AS O ON A.ACT_ID_ORG = O.ORG_ID
            INNER JOIN dbo.InvoiceSaleTable AS I ON A.ACT_ID_INVOICE = I.INS_ID
            INNER JOIN dbo.PeriodTable AS P ON ACT_DATE BETWEEN PR_DATE AND PR_END_DATE
            INNER JOIN dbo.ClientFinancing AS F ON F.ID_CLIENT = A.ACT_ID_CLIENT
            WHERE ACT_ID = @Act_Id
            FOR XML RAW('�����������'), TYPE
        );
        */

        SET @MainBase64 = (SELECT CAST('<?xml version="1.0" encoding="windows-1251" standalone="yes"?>' + Convert(VarChar(Max), @MainContent, 1) AS VarBinary(Max)) FOR XML PATH(''), BINARY BASE64);
        SET @ApplyBase64 = (SELECT CAST('<?xml version="1.0" encoding="windows-1251" standalone="yes"?>' + Convert(VarChar(Max), @ApplyContent, 1) AS VarBinary(Max)) FOR XML PATH(''), BINARY BASE64);

        SET @Data =
        (
            SELECT
                [���������]     = Cast(NewId() AS VarChar(100)),
                [������]        = 'ON_NSCHFDOPPR_' + F.[EIS_CODE] + '_' + O.[EIS_CODE] + '_' + Convert(VarChar(20), GetDate(), 112) + '_' + @File_Id,
                [��������]      = '1.01',
                [���������]     = '�������',
                [������]        = O.[EIS_CODE],
                [�����]         = F.[EIS_CODE],
                [������������]  = GetDate(),
                (
                    SELECT
                        [�������] = @MainBase64
                    FOR XML PATH('��������'), TYPE
                ),
                (
                    SELECT
                        [�������] = @ApplyBase64
                    FOR XML PATH('������'), TYPE
                )
            FROM dbo.ActTable AS A
            INNER JOIN dbo.OrganizationTable AS O ON A.ACT_ID_ORG = O.ORG_ID
            INNER JOIN dbo.ClientFinancing AS F ON F.ID_CLIENT = A.ACT_ID_CLIENT
            WHERE ACT_ID = @Act_Id
            FOR XML RAW('���������'), TYPE
        );

        SELECT
            [Folder]        = RTrim(Ltrim(C.CL_PSEDO)),
            [FileName]      = IsNull(F.[FileName], Cast(NewId() AS VarChar(50))), -- ToDo �������
            [Data]          = F.[Data]
        FROM dbo.ActTable           AS A
        INNER JOIN dbo.ClientTable  AS C ON A.ACT_ID_CLIENT = C.CL_ID
        CROSS APPLY
        (
            SELECT
                [FileName]  = '���_' + C.CL_PSEDO + '_' + Convert(VarChar(50), ACT_DATE, 112) + '_' + @File_Id + '.xml',
                [Data]      = Cast(@Data AS VarChar(Max))
            ---
            UNION ALL
            ---
            SELECT
                [FileName]  = @MainContent.value('(/����/@������)[1]', 'VarChar(256)') + '.xml',
                [Data]      = Cast(@MainContent AS VarChar(Max))
            ---
            UNION ALL
            ---
            SELECT
                [FileName]  = @ApplyContent.value('(/�����������/@��������)[1]', 'VarChar(256)') + '.xml',
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
GRANT EXECUTE ON [dbo].[ACT_PRINT?UPD] TO rl_act_p;
GO