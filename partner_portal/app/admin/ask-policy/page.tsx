'use client';
import {useState} from 'react';
import {useMutation} from '@tanstack/react-query';
import {post} from '@/lib/api';
import {Card,PageHeader,Button} from '@/components/ui';

type PolicyAnswer={answer:string;grounded:boolean;citations:{document_id:string;title:string}[]};
export default function AskPolicy(){
 const [q,setQ]=useState('');
 const m=useMutation({mutationFn:(question:string)=>post<PolicyAnswer>('/admin/ai/ask-policy',{question})});
 return <><PageHeader title="Ask Policy" subtitle="Ask the Admin Knowledge-Base Assistant a policy question."/><Card className="p-6"><div className="flex flex-col gap-3 md:flex-row"><input value={q} onChange={e=>setQ(e.target.value)} onKeyDown={e=>{if(e.key==='Enter'&&q.trim()&&!m.isPending)m.mutate(q.trim())}} placeholder="e.g. When can a customer request a refund?" className="min-w-0 flex-1 rounded-xl border border-line bg-white px-4 py-3 outline-none focus:ring-2 focus:ring-lime-300"/><Button disabled={!q.trim()||m.isPending} onClick={()=>m.mutate(q.trim())}>{m.isPending?'Thinking…':'Ask'}</Button></div>{m.isError&&<p className="mt-4 text-sm font-medium text-red-700">{(m.error as Error).message}</p>}{m.data&&<div className="mt-6 rounded-2xl bg-gray-50 p-5"><p className="leading-7">{m.data.answer}</p><div className="mt-4 border-t pt-3 text-xs font-semibold text-gray-500">{m.data.grounded?'Grounded in policy excerpts':'Grounding check failed'}{m.data.citations?.length>0&&<> · Sources: {m.data.citations.map(c=>c.title).join(', ')}</>}</div></div>}</Card></>;
}
