USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[Company]
(
        [ID]                UniqueIdentifier      NOT NULL,
        [ID_MASTER]         UniqueIdentifier          NULL,
        [SHORT]             NVarChar(256)             NULL,
        [NAME]              NVarChar(896)         NOT NULL,
        [NUMBER]            Int                       NULL,
        [ID_PAY_CAT]        UniqueIdentifier          NULL,
        [ID_WORK_STATE]     UniqueIdentifier          NULL,
        [ID_POTENTIAL]      UniqueIdentifier          NULL,
        [ID_ACTIVITY]       UniqueIdentifier          NULL,
        [ACTIVITY_NOTE]     NVarChar(Max)             NULL,
        [ID_SENDER]         UniqueIdentifier          NULL,
        [SENDER_NOTE]       NVarChar(Max)             NULL,
        [ID_NEXT_MON]       UniqueIdentifier          NULL,
        [WORK_DATE]         SmallDateTime             NULL,
        [DELETE_COMMENT]    NVarChar(512)             NULL,
        [ID_AVAILABILITY]   UniqueIdentifier          NULL,
        [ID_TAXING]         UniqueIdentifier          NULL,
        [ID_WORK_STATUS]    UniqueIdentifier          NULL,
        [ID_CHARACTER]      UniqueIdentifier          NULL,
        [ID_REMOTE]         UniqueIdentifier          NULL,
        [EMAIL]             NVarChar(1024)            NULL,
        [BLACK_LIST]        Bit                       NULL,
        [BLACK_NOTE]        NVarChar(Max)             NULL,
        [STATUS]            TinyInt               NOT NULL,
        [BDATE]             DateTime              NOT NULL,
        [EDATE]             DateTime                  NULL,
        [OLD_ID]            UniqueIdentifier          NULL,
        [UPD_USER]          NVarChar(256)         NOT NULL,
        [WORK_BEGIN]        SmallDateTime             NULL,
        [CARD]              TinyInt                   NULL,
        [PAPER_CARD]        Bit                       NULL,
        [ID_PROJECT]        UniqueIdentifier          NULL,
        [DEPO_NUM]          Int                       NULL,
        [DEPO]              Bit                       NULL,
        CONSTRAINT [PK_Company] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_Company_Company] FOREIGN KEY  ([ID_MASTER]) REFERENCES [Client].[Company] ([ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [IX_ID] ON [Client].[Company] ([ID] ASC);
CREATE NONCLUSTERED INDEX [IX_ACTIVITY] ON [Client].[Company] ([ID_ACTIVITY] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_AVAILABILITY] ON [Client].[Company] ([ID_AVAILABILITY] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_CARD] ON [Client].[Company] ([STATUS] ASC, [CARD] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_CHARACTER] ON [Client].[Company] ([ID_CHARACTER] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_Company_CARD] ON [Client].[Company] ([CARD] ASC) INCLUDE ([ID], [STATUS]);
CREATE NONCLUSTERED INDEX [IX_Company_ID_MASTER_UPD_USER_BDATE] ON [Client].[Company] ([ID_MASTER] ASC, [UPD_USER] ASC, [BDATE] ASC);
CREATE NONCLUSTERED INDEX [IX_EMAIL] ON [Client].[Company] ([EMAIL] ASC, [ID] ASC, [STATUS] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [IX_ID_NAME] ON [Client].[Company] ([ID] ASC) INCLUDE ([NAME]);
CREATE NONCLUSTERED INDEX [IX_MASTER_BDATE] ON [Client].[Company] ([ID_MASTER] ASC, [BDATE] ASC) INCLUDE ([ID_AVAILABILITY]);
CREATE NONCLUSTERED INDEX [IX_MONTH] ON [Client].[Company] ([ID_NEXT_MON] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_NAME] ON [Client].[Company] ([NAME] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_NUMBER] ON [Client].[Company] ([NUMBER] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_PAY_CAT] ON [Client].[Company] ([ID_PAY_CAT] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_POTENTIAL] ON [Client].[Company] ([ID_POTENTIAL] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_REMOTE] ON [Client].[Company] ([ID_REMOTE] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_SENDER] ON [Client].[Company] ([ID_SENDER] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_STATUS] ON [Client].[Company] ([STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_STATUS_NAME] ON [Client].[Company] ([STATUS] ASC) INCLUDE ([ID], [NAME]);
CREATE NONCLUSTERED INDEX [IX_STATUS_WORK_DATE] ON [Client].[Company] ([STATUS] ASC) INCLUDE ([ID], [WORK_DATE]);
CREATE NONCLUSTERED INDEX [IX_WORK_STATE] ON [Client].[Company] ([ID_WORK_STATE] ASC, [STATUS] ASC) INCLUDE ([ID]);
GO
