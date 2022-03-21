import React from 'react';
import ProTable from '@ant-design/pro-table';
import moment from 'moment';
import 'moment/locale/zh-cn';
import { BigNumber } from "bignumber.js";

const BlogTable = (props) => {


    const postColumns = [{
        title: '发布时间',
        dataIndex: 'time',
        valueType: 'dateTime',
        hideInSearch: !props.showTimeFilter,
        width: '200',
        fieldProps: {
            placeholder: '请选择博文的筛选日期'
        }
    }, 
    {
        title: '作者',
        dataIndex: 'author',
        valueType: 'text',
        width: 150,
        hideInTable: !props.showAuthor,
        hideInSearch: true,
    },
    {
        title: '博文内容',
        dataIndex: 'text',
        valueType: 'text',
        width: 300,
        hideInSearch: true
    }];


    return <ProTable
        columns={postColumns}
        options={false}
        actionRef={props.actionRef}
        search={props.showTimeFilter}
        rowKey="time"
        request={async (params = {}, sort, filter) => {
            console.log('request with params', params);
            let minPostTime = !!params.time ? moment(params.time).valueOf() : 0;
            console.log('get minPostTime', minPostTime);
            try {
                let blogs = await props.microblogMethod(minPostTime * 1000000);
                console.log('get blogs', blogs);
                return {
                    data: blogs,
                    success: true,
                    total: blogs.length
                }
            } catch (error) {
                message.error('请求博文历史失败 ' + error);
                return {
                    success: false
                }
            }

        }}
        postData={(data) => {
            data.forEach(entry => {

                let big = new BigNumber(entry.time).dividedBy(1000000).toFixed(0);

                entry.time = new Date(parseInt(big));
                console.log("post time: " + entry.time);
            }
            );
            return data;
        }}
    />
}

export default BlogTable;