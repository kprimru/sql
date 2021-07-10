USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:
���� ��������:  
��������:
*/
ALTER PROCEDURE [dbo].[ACT_PRINT?UPD]
    @Act_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE @Data Xml;

    --EXEC [Debug].[Execution@Start]
      --  @Proc_Id        = @@ProcId,
        --@Params         = @Params,
        --@DebugContext   = @DebugContext OUT

    BEGIN TRY

        SET @Data =
        (
            SELECT
                [���]               = '1115131',
                [�������]           = '���',
                [��������]          = '�������� �� �������� ������� (���������� �����), �������� ������������� ���� (�������� �� �������� �����)',
                [����������]        = '�������� �� �������� ������� (���������� �����), �������� ������������� ���� (�������� �� �������� �����)',
                [���������������]   = O.ORG_FULL_NAME,
                [�������������]     = '0000.0000.0000',
                (
                    SELECT
                        [��������]  = I.INS_NUM,
                        [�������]   = I.INS_DATE,
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
                                [���������] = CL.CL_SHORT_NAME,
                                (
                                    SELECT
                                        [�������]   = CL.CL_FULL_NAME,
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
                                        [�����������]   = CO_DATE,
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
                                [������]        = Row_Number() OVER(ORDER BY SYS_ORDER, DIS_NUM, DIS_COMP_NUM),
                                [�������]       = R.INR_GOOD + ' ' + R.INR_NAME,
                                [����_���]      = S.SO_OKEI,
                                [������]        = IsNull(R.INR_COUNT, 1),
                                [�������]       = R.INR_SUM,
                                [�����������]   = R.INR_SUM * IsNull(R.INR_COUNT, 1),
                                [�����]         = Cast(Cast(T.TX_PERCENT AS Int) AS VarChar(10)) + ' %',
                                [����������]    = R.INR_SALL,
                                (
                                    SELECT
                                        [��������] = '��� ������'
                                    FOR XML PATH('�����'), TYPE
                                ),
                                (
                                    SELECT
                                        [������] = R.INR_SNDS
                                    FOR XML PATH('������'), TYPE
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
                                [����������������]  = Sum(R.INR_SUM * IsNull(R.INR_COUNT, 1)),
                                [���������������]   = Sum(R.INR_SALL),
                                (
                                    SELECT
                                        [������] = Sum(R.INR_SNDS)
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
                                [�������]   = ACT_DATE,
                                [�������]   = PR_DATE,
                                [��������]  = PR_END_DATE,
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
            FROM dbo.ActTable AS A
            INNER JOIN dbo.OrganizationTable AS O ON A.ACT_ID_ORG = O.ORG_ID
            INNER JOIN dbo.InvoiceSaleTable AS I ON A.ACT_ID_INVOICE = I.INS_ID
            INNER JOIN dbo.PeriodTable AS P ON ACT_DATE BETWEEN PR_DATE AND PR_END_DATE
            WHERE ACT_ID = @Act_Id
            FOR XML RAW('��������'), TYPE
        );

        SELECT @Data AS DATA;

        --EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        --SET @DebugError = Error_Message();

        --EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_PRINT?UPD] TO rl_act_p;
GO