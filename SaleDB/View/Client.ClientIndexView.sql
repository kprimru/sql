USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Client].[ClientIndexView]
AS
    SELECT
        A.ID,
        [Data] =
            ISNULL(a.SHORT, '') + ' ' +
            ISNULL(a.NAME, '') + ' ' +
            ISNULL(a.EMAIL, '') + ' ' +
            ISNULL(CONVERT(VARCHAR(20), a.NUMBER), '') + ' ' +
            ISNULL(
                (
                    SELECT
                        ISNULL(b.NAME, '') + ' ' +
                        ISNULL(b.SHORT, '') + ' ' +
                        ISNULL(d.NAME, '') + ' ' +
                        ISNULL(e.NAME, '') + ' ' +
                        ISNULL(f.NAME, '') + ' ' +
                        ISNULL(c.HOME, '') + ' ' +
                        ISNULL(c.ROOM, '') + ' ' +
                        ISNULL(c.NOTE, '')
                    FROM Client.Office b
                    LEFT JOIN Client.OfficeAddress c ON c.ID_OFFICE = b.ID
                    LEFT JOIN Address.Street d ON d.ID = c.ID_STREET
                    LEFT JOIN Address.City e ON e.ID = d.ID_CITY
                    LEFT JOIN Address.Area f ON f.ID = c.ID_AREA
                    WHERE b.ID_COMPANY = a.ID AND b.STATUS = 1
                    FOR XML PATH('')
                ), '') + ' ' +
            ISNULL(
                (
                    SELECT
                        ISNULL(PHONE, '') + ' ' +
                        ISNULL(PHONE_S, '') + ' '
                    FROM Client.CompanyPhone b
                    WHERE b.ID_COMPANY = a.ID
                    FOR XML PATH('')
                )
                , '') + ' ' +
            ISNULL(
                (
                    SELECT
                        ISNULL(FIO, '') + ' ' +
                        ISNULL(EMAIL, '') + ' ' +
                        ISNULL(
                            (
                                SELECT
                                    ISNULL(PHONE, '') + ' ' +
                                    ISNULL(PHONE_S, '') + ' '
                                FROM Client.CompanyPersonalPhone c
                                WHERE b.ID = c.ID_PERSONAL
                                FOR XML PATH('')
                            )
                            , '') + ' '
                    FROM Client.CompanyPersonal b
                    WHERE b.ID_COMPANY = a.ID
                    FOR XML PATH('')
                )
                , '')  +
            ISNULL(
                (
                    SELECT ISNULL(b.SHORT, '') + ' ' + ISNULL(b.SURNAME, '')
                    FROM Personal.OfficePersonal b
                    INNER JOIN Client.CompanyProcessPhoneView c WITH(NOEXPAND) ON b.ID = c.ID_PERSONAL
                    WHERE c.ID = a.ID
                )
            , '') +
            ISNULL(
                (
                    SELECT ISNULL(b.SHORT, '') + ' ' + ISNULL(b.SURNAME, '')
                    FROM Personal.OfficePersonal b
                    INNER JOIN Client.CompanyProcessManagerView c WITH(NOEXPAND) ON b.ID = c.ID_PERSONAL
                    WHERE c.ID = a.ID
                )
            , '') +
            ISNULL(
                (
                    SELECT ISNULL(b.SHORT, '') + ' ' + ISNULL(b.SURNAME, '')
                    FROM Personal.OfficePersonal b
                    INNER JOIN Client.CompanyProcessSaleView c WITH(NOEXPAND) ON b.ID = c.ID_PERSONAL
                    WHERE c.ID = a.ID
                )
            , ''),
            AVA_COLOR = xxx.COLOR,
            SenderIndex = YYY.INDX
    FROM Client.Company a
    LEFT JOIN Client.Availability AS xxx ON a.ID_AVAILABILITY = xxx.ID
    LEFT JOIN Client.Sender AS yyy ON a.ID_SENDER = yyy.ID
    WHERE a.STATUS = 1GO
